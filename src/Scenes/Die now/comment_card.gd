extends PanelContainer


const card_type := &'comment'
var text: String


@warning_ignore("shadowed_variable")
func set_text(text:String) -> void:
	self.text = text
	$HBox/Text.text = text


func _on_text_text_changed() -> void:
	text = $HBox/Text.text


func _on_remove_pressed() -> void:
	self.queue_free()
