extends Node3D

@onready var glyph_1 = $Node3D/Glyph1
@onready var glyph_2 = $Node3D/Glyph2
@onready var glyph_3 = $Node3D/Glyph3
@onready var glyph_4 = $Node3D/Glyph4


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func setGlyph(rune_image: CompressedTexture2D):
	if rune_image:
		var material = StandardMaterial3D.new()
		material.set_texture(
			BaseMaterial3D.TEXTURE_ALBEDO,
			rune_image
		)
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		for mesh in [glyph_1, glyph_2, glyph_3, glyph_4]:
			mesh.material_override = material

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
