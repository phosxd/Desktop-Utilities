extends VBoxContainer

@onready var tree = get_tree()
@onready var file_menu_popup:PopupMenu = %File.get_popup()
@onready var id_count:int = %'ID Count'.value
@onready var part_joiner:String = %'Part joiner'.text


func generate() -> PackedStringArray:
	var result := PackedStringArray()

	for part:Control in %Parts.get_children():
		if not part.name.begins_with('Part'): continue
		var part_result:PackedStringArray = part.generate()

		var valid := false
		for item in part_result:
			if not item.is_empty(): valid = true
		if not valid: continue

		result.append(''.join(part_result))

	return result


# File functions.
# ---------------

func save_file() -> void:
	var file_dialog := FileDialog.new()
	file_dialog.title = 'Save your custom ID generator'
	file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.add_filter('*.json')
	file_dialog.current_file = 'new_id_generator.json'
	file_dialog.file_selected.connect(_save_file)
	file_dialog.use_native_dialog = true
	file_dialog.force_native = true
	file_dialog.min_size = Vector2i(175, 100)
	file_dialog.show()


func _save_file(path:String) -> void:
	var json:Dictionary[String,Variant] = {
		'.HEADER': {
			'type': 'd-id ruleset',
			'version': '1',
		},
		'id_count': id_count,
		'part_joiner': part_joiner,
		'parts': []
	}
	for part:Control in %Parts.get_children():
		if not part.name.begins_with('Part'): continue
		json.parts.append(part.get_options())

	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(json))
	file.close()


func load_file() -> void:
	var file_dialog := FileDialog.new()
	file_dialog.title = 'Load a custom ID generator'
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.add_filter('*.json')
	file_dialog.file_selected.connect(_load_file)
	file_dialog.use_native_dialog = true
	file_dialog.force_native = true
	file_dialog.min_size = Vector2i(175, 100)
	file_dialog.show()


func _load_file(path:String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	var text := file.get_as_text()
	file.close()
	
	var json = JSON.parse_string(text)
	if json is not Dictionary:
		printerr('Invalid JSON.')
		return
	var header = json.get('.HEADER')
	if header.get('type', '') != 'd-id ruleset':
		printerr('Wrong header type.')
		return
	if header.get('version', -1) != '1':
		printerr('Wrong header version.')
		return
	
	id_count = json.get('id_count', id_count)
	part_joiner = json.get('part_joiner', part_joiner)
	%'ID Count'.value = id_count
	%'Part joiner'.text = part_joiner
	
	var json_parts:Array = json.get('parts', [])
	var index:int = -1
	for part:Control in %Parts.get_children():
		if not part.name.begins_with('Part'): continue
		index += 1
		var json_part = json_parts.get(index)
		if json_part is not Dictionary: continue
		part.set_options(json_part)
		


# Callbacks.
# ----------

func _ready() -> void:
	file_menu_popup.id_pressed.connect(_file_menu_button_pressed)


func _process(_delta:float) -> void:
	if Input.is_action_just_pressed('ctrl-s'):
		save_file()
	if Input.is_action_just_pressed('ctrl-l'):
		load_file()


func _file_menu_button_pressed(id:int) -> void:
	match id:
		0: save_file()
		1: load_file()


func _on_home_pressed() -> void:
	tree.change_scene_to_file('res://Scenes/Home/home.tscn')


func _on_id_count_value_changed(value:float) -> void:
	id_count = int(value)


func _on_generate_pressed() -> void:
	var lines := PackedStringArray()
	# Generate IDs.
	for i in range(id_count):
		lines.append(part_joiner.join(generate()))
	# Set output.
	%Output.text = '\n'.join(lines)


func _on_copy_pressed() -> void:
	DisplayServer.clipboard_set(%Output.text)


func _on_part_joiner_text_changed(new_text:String) -> void:
	part_joiner = new_text
