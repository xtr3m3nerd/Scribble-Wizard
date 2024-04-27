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

func _ready():
	prep_image_data()
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

var image_data = {}
func prep_image_data():
	var dir = DirAccess.open("res://assets/glyphs")
	if dir:
		dir.list_dir_begin()
		var glyph_type = dir.get_next()
		while glyph_type != "":
			if dir.current_is_dir():
				image_data[glyph_type] = []
				var sub_dir = DirAccess.open("res://assets/glyphs/"+glyph_type)
				if sub_dir:
					sub_dir.list_dir_begin()
					var file_name = sub_dir.get_next()
					while file_name != "":
						if not file_name.ends_with(".import"):
							var base_img = Image.load_from_file("res://assets/glyphs/"+glyph_type+"/"+file_name)
							base_img.resize(48,48)
							base_img.convert(Image.FORMAT_RGB8)
							var base_img_data = base_img.get_data()
							image_data[glyph_type].append(base_img_data)
						file_name = sub_dir.get_next()
					file_name = sub_dir.get_next()
			glyph_type = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

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
	for glyph_type in image_data.keys():
		for base_img_data in image_data[glyph_type]:
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
