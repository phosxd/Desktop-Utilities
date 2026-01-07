extends VBoxContainer

const max_content_split_offset := 300
const font_property_names:Array[String] = [
	'normal',
	'bold',
	'bold_italics',
	'italics',
	'mono',
]

@onready var tree = get_tree()
@onready var file_menu_popup:PopupMenu = %File.get_popup()
@onready var editor_menu_popup:PopupMenu = %Editor.get_popup()
@onready var font_menu_popup:PopupMenu = %Font.get_popup()


# File functions.
# ---------------

func save_file() -> void:
	PopupTool.popup_file_save('Save your note', PackedStringArray(['*.txt','*.md']), 'new_note.txt', _save_file)


func _save_file(path:String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(%'Text Box'.text)
	file.close()


func load_file() -> void:
	PopupTool.popup_file_load('Load a note', PackedStringArray(['*.txt','*.md']), _load_file)


func _load_file(path:String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	var text := file.get_as_text()
	file.close()
	%'Text Box'.text = text
	%'Markdown Preview'.markdown_text = text


func store_settings_in_text() -> void:
	%'Text Box'.text = """@dtu-np font %s
@dtu-np font_size %s
@dtu-np line_wrap %s
@dtu-np show_spaces %s
@dtu-np show_tabs %s
@dtu-np show_line_numbers %s

""" % [
		font_menu_popup.get_item_text(0).replace('Current: ', ''),
		%'Zoom'.value,
		%'Text Box'.wrap_mode,
		%'Text Box'.draw_spaces,
		%'Text Box'.draw_tabs,
		%'Text Box'.gutters_draw_line_numbers,
	] + %'Text Box'.text


# Editor functions.
# -----------------

func toggle_editor_property(id:int) -> void:
	var is_item_checked:bool = editor_menu_popup.is_item_checked(id)
	editor_menu_popup.set_item_checked(id, not is_item_checked)
	match id:
		0: %'Text Box'.wrap_mode = not is_item_checked
		1: %'Text Box'.draw_spaces = not is_item_checked
		2: %'Text Box'.draw_tabs = not is_item_checked
		3: %'Text Box'.gutters_draw_line_numbers = not is_item_checked


# Callbacks.
# ----------

func _ready() -> void:
	file_menu_popup.id_pressed.connect(_file_menu_button_pressed)
	editor_menu_popup.id_pressed.connect(_editor_menu_button_pressed)
	font_menu_popup.id_pressed.connect(_font_menu_button_pressed)
	var system_fonts := OS.get_system_fonts()
	for font in system_fonts:
		font_menu_popup.add_item(font)

	_on_zoom_value_changed(%Zoom.value)
	_on_text_box_text_changed()
	_on_text_box_caret_changed()


func _process(_delta:float) -> void:
	if Input.is_action_just_pressed('ctrl-s'):
		save_file()
	if Input.is_action_just_pressed('ctrl-l'):
		load_file()


func _on_home_pressed() -> void:
	tree.change_scene_to_file('res://Scenes/Home/home.tscn')


func _file_menu_button_pressed(id:int) -> void:
	match id:
		0: save_file()
		1: load_file()
		2: store_settings_in_text()


func _editor_menu_button_pressed(id:int) -> void:
	toggle_editor_property(id)


func _font_menu_button_pressed(id:int) -> void:
	var font_name := font_menu_popup.get_item_text(id)
	font_menu_popup.set_item_text(0, 'Current: '+font_name)

	# Set to default.
	if id == 1:
		%'Text Box'.remove_theme_font_override('font')
		for font_property_name in font_property_names:
			%'Markdown Preview'.remove_theme_font_override(font_property_name+'_font')
		return

	# Set system font.
	var system_font := SystemFont.new()
	system_font.font_names = PackedStringArray([font_name])
	%'Text Box'.add_theme_font_override('font', system_font)
	for font_property_name in font_property_names:
		%'Markdown Preview'.add_theme_font_override(font_property_name+'_font', system_font)


func _on_text_box_text_changed() -> void:
	var text:String = %'Text Box'.text
	%'Markdown Preview'.markdown_text = text
	%Length.text = 'Len ' + str(text.length())
	%Bytes.text = str(text.to_utf8_buffer().size()) + ' Bytes (UTF-8)'

	# Update editor settings.
	var settings_found:Array[String] = []
	for line:String in text.split('\n'):
		if line.begins_with('@dtu-np '):
			var setting_name := line.split(' ')[1]
			var setting_value := line.replace('@dtu-np '+setting_name+' ', '')
			if settings_found.has(setting_name): continue
			match setting_name:
				'font':
					settings_found.append('font')
					var font_index:int = -1
					for i in range(font_menu_popup.item_count):
						if font_menu_popup.get_item_text(i) == setting_value:
							font_index = i
							break
					if font_index != -1:
						_font_menu_button_pressed(font_index)
				'font_size':
					settings_found.append('font_size')
					%'Zoom'.value = int(setting_value)
				'line_wrap':
					settings_found.append('line_wrap')
					%'Text Box'.wrap_mode = int(setting_value)
				'show_spaces':
					settings_found.append('show_spaces')
					%'Text Box'.draw_spaces = setting_value == 'true'
				'show_tabs':
					settings_found.append('show_tabs')
					%'Text Box'.draw_tabs = setting_value == 'true'
				'show_line_numbers':
					settings_found.append('show_line_numbers')
					%'Text Box'.gutters_draw_line_numbers = setting_value == 'true'


func _on_text_box_caret_changed() -> void:
	%'Collumn'.text = 'Col ' + str(%'Text Box'.get_caret_column())
	%'Line'.text = 'Ln ' + str(%'Text Box'.get_caret_line())


func _on_toggle_markdown_pressed() -> void:
	%'Markdown Preview'.visible = %'Toggle Markdown'.button_pressed


func _on_content_split_dragged(offset:int) -> void:
	if abs(offset) > max_content_split_offset:
		%'Content Split'.split_offset = max_content_split_offset if offset > 0 else -max_content_split_offset


func _on_zoom_value_changed(value:int) -> void:
	%'Zoom Label'.text = str(value)+'px'
	%'Text Box'.remove_theme_font_size_override('font_size')
	%'Text Box'.add_theme_font_size_override('font_size', value)
	for font_property_name in font_property_names:
		%'Markdown Preview'.remove_theme_font_size_override(font_property_name+'_font_size')
		%'Markdown Preview'.add_theme_font_size_override(font_property_name+'_font_size', value)
