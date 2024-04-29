@tool
extends Node

@export var run_training = false:
	set(value):
		run_training = value
		if value:
			try_run_training()

var image_directory := "res://assets/glyphs"
var output_file := "res://assets/training_data/training_data.tres"

func try_run_training():
	print("hello world")
	var data = prep_image_data()
	var error = ResourceSaver.save(data, output_file)
	if error != OK:
		print("An error occurred while saving the resource.")
	else:
		print("Dictionary saved to resource file: ", output_file)
	#save_dictionary_to_file(data, output_file)
	run_training = false

static func image_load_no_warning(filepath):
	var image = Image.new()
	image.load(ProjectSettings.globalize_path(filepath))
	return image

func process_image_to_bitmap_data(base_img):
	# This method should match the algorithm for bitmap processing in the Cast Zone
	base_img.resize(48,48)
	base_img.convert(Image.FORMAT_RGB8)
	var base_img_data = base_img.get_data()
	
	var drawn_bitmap = BitMap.new()
	drawn_bitmap.create(Vector2i(48,48))
	
	for i in range(0,len(base_img_data),3):
		if base_img_data[i] > 150:
			var y = int((i/3.)/48.)
			var x = int(i/3.)%48
			drawn_bitmap.set_bit(x, y, true )
	
	drawn_bitmap.resize(Vector2i(256, 256))
	
	# This gives us a roughly equal number of pixels across all glyphs, allowing us to use one threshold value.
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

func prep_image_data() -> TrainingData:
	var image_data = TrainingData.new()
	print("LOAD IMAGES")
	var dir = DirAccess.open(image_directory)
	var count = 0
	if dir:
		dir.list_dir_begin()
		var glyph_type = dir.get_next()
		while glyph_type != "":
			print(glyph_type)
			if dir.current_is_dir():
				print("current_is_dir")
				image_data.data[glyph_type] = []
				var sub_dir = DirAccess.open(image_directory+"/"+glyph_type)
				if sub_dir:
					print("sub_dir")
					sub_dir.list_dir_begin()
					var file_name = sub_dir.get_next()
					print(file_name)
					while file_name != "":
						if not file_name.ends_with(".import"):
							print(file_name)
							var base_img = image_load_no_warning(image_directory+"/"+glyph_type+"/"+file_name)
							var raw_bitmap_data = process_image_to_bitmap_data(base_img)
							count += 1
							print(count)
							image_data.data[glyph_type].append(raw_bitmap_data)
						file_name = sub_dir.get_next()
						print(file_name)
					file_name = sub_dir.get_next()
					print(file_name)
			glyph_type = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return image_data
	
func save_dictionary_to_file(dict, file_path):
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file != null:
		file.store_line(JSON.stringify(dict))
		file.close()
		print("Dictionary saved to file: ", file_path)
	else:
		print("Error: Could not open file for writing: ", file_path)
