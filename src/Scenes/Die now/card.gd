extends PanelContainer

var process: RefCounted


@warning_ignore('shadowed_variable')
func update(process:RefCounted, process_running:bool) -> void:
	self.process = process
	$'HBox/Process name'.text = process.name
	$'HBox/Copy path'.tooltip_text = process.path
	if process.path.is_empty():
		$'HBox/Copy path'.disabled = true
	$'HBox/Running indicator off'.visible = not process_running
	$'HBox/Running indicator on'.visible = process_running
	$HBox/Kill.disabled = not process_running


func _on_kill_pressed() -> void:
	process.kill()
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
