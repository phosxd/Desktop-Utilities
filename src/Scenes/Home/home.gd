extends VBoxContainer

@onready var tree = get_tree()


func _on_notepad_pressed() -> void:
	tree.change_scene_to_file('res://Scenes/Notepad/notepad.tscn')


func _on_englueh_pressed() -> void:
	tree.change_scene_to_file('res://Scenes/Englueh/englueh.tscn')


func _on_uuid_pressed() -> void:
	tree.change_scene_to_file('res://Scenes/UUID/uuid.tscn')


func _on_did_pressed() -> void:
	tree.change_scene_to_file('res://Scenes/D-ID/d-id.tscn')
