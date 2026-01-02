extends VBoxContainer

@onready var tree = get_tree()
@onready var uuid_count:int = %'UUID Count'.value


# Callbacks.
# ----------

func _ready() -> void:
	pass


func _process(_delta:float) -> void:
	pass


func _on_home_pressed() -> void:
	tree.change_scene_to_file('res://Scenes/Home/home.tscn')


func _on_uuid_count_value_changed(value:float) -> void:
	uuid_count = int(value)


func _on_generate_pressed() -> void:
	var lines := PackedStringArray()
	# Generate UUIDs.
	for i in range(uuid_count):
		lines.append(UUID_v4.v4())
	# Set output.
	%Output.clear()
	%Output.text = '\n'.join(lines)


func _on_copy_pressed() -> void:
	DisplayServer.clipboard_set(%Output.text)
