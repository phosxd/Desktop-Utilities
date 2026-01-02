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
	PopupTool.popup_file_save('Save your custom ID generator', PackedStringArray(['*.json']), 'new_id_generator.json', _save_file)


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
	PopupTool.popup_file_load('Load a custom ID generator', PackedStringArray(['*.json']), _load_file)


func _load_file(path:String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	var text := file.get_as_text()
	file.close()
	
	var json = JSON.parse_string(text)
	if json is not Dictionary:
		OS.alert('File contains invalid JSON.', 'Error')
		return
	var header = json.get('.HEADER')
	if header.get('type', '') != 'd-id ruleset':
		OS.alert('JSON contains wrong header type. Expected "d-id ruleset".', 'Error')
		return
	if header.get('version', 'unknown') != '1':
		OS.alert('JSON contains wrong header version. Expected "1".', 'Error')
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
	%Output.clear()
	%Output.text = '\n'.join(lines)


func _on_copy_pressed() -> void:
	DisplayServer.clipboard_set(%Output.text)


func _on_part_joiner_text_changed(new_text:String) -> void:
	part_joiner = new_text
