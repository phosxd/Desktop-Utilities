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
	var file_dialog := FileDialog.new()
	file_dialog.title = 'Save your note'
	file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.add_filter('*.txt')
	file_dialog.add_filter('*.md')
	file_dialog.current_file = 'new_note.txt'
	file_dialog.file_selected.connect(_save_file)
	file_dialog.use_native_dialog = true
	file_dialog.force_native = true
	file_dialog.min_size = Vector2i(175, 100)
	file_dialog.show()


func _save_file(path:String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(%'Text Box'.text)
	file.close()


func load_file() -> void:
	var file_dialog := FileDialog.new()
	file_dialog.title = 'Load a note'
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.add_filter('*.txt')
	file_dialog.add_filter('*.md')
	file_dialog.file_selected.connect(_load_file)
	file_dialog.use_native_dialog = true
	file_dialog.force_native = true
	file_dialog.min_size = Vector2i(175, 100)
	file_dialog.show()


func _load_file(path:String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	var text := file.get_as_text()
	file.close()
	%'Text Box'.text = text
	%'Markdown Preview'.markdown_text = text


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
	%'Markdown Preview'.markdown_text = %'Text Box'.text


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
