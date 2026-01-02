extends PanelContainer


const card_type := &'process'
@onready var flags_menu_popup:PopupMenu = $HBox/Flags.get_popup()
var process: RefCounted
var process_running:bool = false
var forceful:bool = false


@warning_ignore('shadowed_variable')
func update(process:RefCounted, process_running:bool) -> void:
	self.process = process
	self.process_running = process_running
	$'HBox/Process name'.text = process.name
	$'HBox/Process name'.tooltip_text = 'Process ID: '+str(process.pid)
	$'HBox/Copy path'.tooltip_text = process.path
	if process.path.is_empty():
		$'HBox/Copy path'.disabled = true
	$'HBox/Running indicator off'.visible = not process_running
	$'HBox/Running indicator on'.visible = process_running
	$HBox/Kill.disabled = not process_running


func toggle_property(id:int) -> void:
	var is_item_checked:bool = flags_menu_popup.is_item_checked(id)
	flags_menu_popup.set_item_checked(id, not is_item_checked)
	match id:
		0: forceful = not is_item_checked


func set_property(id:int, value:bool) -> void:
	flags_menu_popup.set_item_checked(id, value)
	match id:
		0: forceful = value


func _ready() -> void:
	flags_menu_popup.id_pressed.connect(_flags_menu_button_pressed)


func _flags_menu_button_pressed(id:int) -> void:
	toggle_property(id)


func _on_kill_pressed() -> void:
	var exit_code:int = process.kill(forceful)
	if exit_code != -1:
		update(process, false)


func _on_remove_pressed() -> void:
	self.queue_free()


func _on_copy_path_pressed() -> void:
	DisplayServer.clipboard_set(process.path)


func _on_move_gui_input(event:InputEvent) -> void:
	if event.is_action_released('mouse_left'):
		var value = $HBox/Move.value
		if value == 0.5: return # Do nothing if scoll bar set to middle.
		# If scroll bar moved up or down, move the card.
		if value > 0.5:
			get_parent().move_child(self, self.get_index()+1)
		if value < 0.5:
			get_parent().move_child(self, self.get_index()-1)
		# Reset scroll bar to middle.
		$HBox/Move.value = 0.5


func _on_forceful_toggled(toggled_on:bool) -> void:
	forceful = toggled_on
