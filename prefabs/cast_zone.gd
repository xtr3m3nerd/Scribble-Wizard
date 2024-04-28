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

func send_drawing():
	start_cast.emit()
	await RenderingServer.frame_post_draw
	var image = sub_viewport.get_texture().get_image()
	var bounding_rect = image.get_used_rect()
	var cropped = image.get_region(bounding_rect)
	cropped.resize(48,48)
	cropped.convert(Image.FORMAT_RGB8)
	var buffer = cropped.save_png_to_buffer()
	
	var drawn_image_data = cropped.get_data()
	
	# Calculate directly
	var best_match = null
	var best_match_score = 0
	for glyph_type in image_data.data.keys():
		for base_img_data in image_data.data[glyph_type]:
			var total = 0
			for i in range(0,len(base_img_data),3):
				total += abs(drawn_image_data[i] - base_img_data[i])
			if total > best_match_score:
				best_match_score = total
				best_match = glyph_type
	if best_match_score > 450000:
		cast.emit([best_match])
		print(best_match + " " + str(best_match_score))
	else:
		bad_cast.emit()
		print("Bad Glyph" + " "+ str(best_match_score))
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
