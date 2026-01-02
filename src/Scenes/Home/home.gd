extends VBoxContainer

@onready var tree = get_tree()
@onready var user_menu_popup:PopupMenu = %User.get_popup()


func _ready() -> void:
	user_menu_popup.id_pressed.connect(_user_menu_popup_button_pressed)


func _user_menu_popup_button_pressed(id:int) -> void:
	match id:
		0: OS.shell_open(ProjectSettings.globalize_path('user://'))


func _on_notepad_pressed() -> void:
	tree.change_scene_to_file('res://Scenes/Notepad/notepad.tscn')


func _on_englueh_pressed() -> void:
	tree.change_scene_to_file('res://Scenes/Englueh/englueh.tscn')


func _on_uuid_pressed() -> void:
	tree.change_scene_to_file('res://Scenes/UUID/uuid.tscn')


func _on_did_pressed() -> void:
	tree.change_scene_to_file('res://Scenes/D-ID/d-id.tscn')


func _on_die_now_pressed() -> void:
	tree.change_scene_to_file('res://Scenes/Die now/die now.tscn')
