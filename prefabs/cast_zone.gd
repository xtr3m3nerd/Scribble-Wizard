class_name CastZone
extends Control

@onready var sub_viewport = $SubViewport as SubViewport
@onready var visuals = $Visuals as TextureRect
@onready var brush = $SubViewport/Brush as Sprite2D

@export var capture_size: Vector2i = Vector2i(128,128)

var drawing = false

var x_scale: float
var y_scale: float

var temp_filepath = "user://tmp.png"
var url = "http://192.168.1.138:3000/image"

func _ready():
	sub_viewport.size = capture_size
	brush.hide()
	update_viewport_scale()
	clear()
	
func _input(event):
	if event.is_action_pressed("draw"):
		drawing = true
		brush.show()
	if event.is_action_released("draw"):
		drawing = false
		brush.hide()
		await RenderingServer.frame_post_draw
		var image = sub_viewport.get_texture().get_image()
		var buffer = image.save_png_to_buffer()
		var image_base64 = Marshalls.raw_to_base64(buffer)
		var data = {
			"image": "data:image/png;base64," + image_base64
		}
		var json = JSON.stringify(data)
		var headers = ["Content-Type: application/json"]
		var http_request = HTTPRequest.new()
		add_child(http_request)
		http_request.request_completed.connect(_on_request_completed.bind(http_request))
		http_request.request(url, headers, HTTPClient.METHOD_POST, json)
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

func _on_request_completed(_result, _response_code, _headers, body, http_node):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json)
	for glyph in json:
		if glyph["type"] == "lightning":
			$"../..".shoot(glyph["type"])
	http_node.queue_free()
