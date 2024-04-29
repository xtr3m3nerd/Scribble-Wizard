class_name CastZone
extends Control

signal start_draw
signal start_cast
signal bad_cast
signal cast(types)

@onready var sub_viewport = $SubViewport as SubViewport
@onready var visuals = $Visuals as TextureRect
@onready var brush = $SubViewport/Brush as Sprite2D

@export var capture_size: Vector2i = Vector2i(128,128)

var drawing = false
var continue_drawing = false

var x_scale: float
var y_scale: float

var training_file := "res://assets/training_data/training_data.tres"
var image_data: TrainingData

func _ready():
	#image_data = load_dictionary_from_file(training_file)
	image_data = ResourceLoader.load(training_file)
	sub_viewport.size = capture_size
	brush.hide()
	update_viewport_scale()
	clear()
	
func _input(event):
	if event.is_action_pressed("draw"):
		drawing = true
		brush.show()
		start_draw.emit()
	if event.is_action_released("draw"):
		drawing = false
		brush.hide()
		send_drawing()

func load_dictionary_from_file(file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file != null:
		var json_string = file.get_as_text()
		var parsed_data = JSON.parse_string(json_string)
		if parsed_data is Dictionary:
			file.close()
			return parsed_data
		else:
			print("Error: Parsed data is not a Dictionary.")
	else:
		print("Error: Could not open file for reading: ", file_path)
	
	file.close()
	return {}

func random_filename(length):
	var characters = 'abcdefghijklmnopqrstuvwxyz'
	var word: String = ""
	for i in range(length):
		word += characters[randi() % len(characters)]
	return word

func get_image_data(image):
	var bounding_rect = image.get_used_rect()
	var cropped = image.get_region(bounding_rect)
	cropped.resize(48,48)
	cropped.convert(Image.FORMAT_RGB8)
	#cropped.save_png("res://assets/glyphs/new/" + random_filename(5) + ".png")
	
	var drawn_image_data = cropped.get_data()
	return drawn_image_data

func process_image_to_bitmap(drawn_image_data):
	# This method should match the algorithm for bitmap processing in the pretrainer.
	var drawn_bitmap = BitMap.new()
	drawn_bitmap.create(Vector2i(48,48))
	
	for i in range(0,len(drawn_image_data),3):
		if drawn_image_data[i] > 150:
			var y = int((i/3.)/48.)
			var x = int(i/3.)%48
			drawn_bitmap.set_bit(x, y, true )
	
	drawn_bitmap.resize(Vector2i(256, 256))
	
	while drawn_bitmap.get_true_bit_count() > 20000:
		drawn_bitmap.grow_mask(-1, Rect2(Vector2(), drawn_bitmap.get_size()))
	while drawn_bitmap.get_true_bit_count() < 20000:
		drawn_bitmap.grow_mask(1, Rect2(Vector2(), drawn_bitmap.get_size()))
	
	drawn_bitmap.resize(Vector2i(48, 48))
	
	var raw_bitmap_data = []
	for x in range(0, 48):
		for y in range(0, 48):
			raw_bitmap_data.append(1 if drawn_bitmap.get_bit(x, y) else 0)
			
	return raw_bitmap_data
	
func send_drawing():
	start_cast.emit()
	await RenderingServer.frame_post_draw
	var image = sub_viewport.get_texture().get_image()
	if image.get_size().x == 0 or image.get_size().y == 0:
		bad_cast.emit()
		print("Bad Glyph")
		clear()
		return
	
	var drawn_bitmap_data = process_image_to_bitmap(get_image_data(image))
	
	# Calculate directly
	var best_match = {}
	var best_match_score = {}
	for glyph_type in image_data.data.keys():
		best_match[glyph_type] = null
		best_match_score[glyph_type] = 0
		
		for base_img_bitmap_data in image_data.data[glyph_type]:
			var total = 0
			for i in range(0, 48*48):
				total += 1 if base_img_bitmap_data[i] == drawn_bitmap_data[i] else -1
			
			if total > best_match_score[glyph_type]:
				best_match_score[glyph_type] = total
				best_match[glyph_type] = glyph_type
	var matches = []
	
	#print(best_match_score)
	#print(best_match)
	
	for glyph_type in image_data.data.keys():
		if best_match_score[glyph_type] > 1200:
			matches.append(glyph_type)
	
	if matches:
		cast.emit(matches)
		print(matches)
	else:
		bad_cast.emit()
		print("Bad Glyph")
	clear()

func _process(_delta):
	var mouse_pos = get_global_mouse_position()
	brush.position.x = mouse_pos.x * x_scale
	brush.position.y = mouse_pos.y * y_scale

func update_viewport_scale():
	x_scale = capture_size.x / get_viewport_rect().size.x
	y_scale = capture_size.y / get_viewport_rect().size.y
	brush.scale.x = x_scale
	brush.scale.y = y_scale

func clear():
	RenderingServer.viewport_set_clear_mode(sub_viewport.get_viewport_rid(),RenderingServer.VIEWPORT_CLEAR_ONLY_NEXT_FRAME)
