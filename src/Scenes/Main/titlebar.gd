extends PanelContainer

var following := false
var dragging_start_position := Vector2()
@onready var window := get_window()


func _on_gui_input(event:InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.get_button_index() == 1:
			following = !following
			dragging_start_position = get_local_mouse_position()


func _process(_delta):
	if following:
		window.position = (window.position + Vector2i(get_global_mouse_position() - dragging_start_position))


func _on_close_pressed() -> void:
	get_tree().quit()


func _on_minimize_pressed() -> void:
	window.mode = Window.MODE_MINIMIZED


func _on_maximize_pressed() -> void:
	if window.mode == Window.MODE_MAXIMIZED:
		window.mode = Window.MODE_WINDOWED
	else:
		window.mode = Window.MODE_MAXIMIZED
