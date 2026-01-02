class_name PopupTool extends RefCounted


static func popup_file_load(title:String, filters:PackedStringArray, callback:Callable) -> FileDialog:
	var dialog := FileDialog.new()
	dialog.use_native_dialog = true
	dialog.min_size = Vector2i(175, 100)
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE

	dialog.title = title
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	for filter in filters:
		dialog.add_filter(filter)
	dialog.file_selected.connect(callback)
	dialog.show()
	return dialog


static func popup_file_save(title:String, filters:PackedStringArray, current_file_name:String, callback:Callable) -> FileDialog:
	var dialog := FileDialog.new()
	dialog.use_native_dialog = true
	dialog.min_size = Vector2i(175, 100)
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE

	dialog.title = title
	for filter in filters:
		dialog.add_filter(filter)
	dialog.current_file = current_file_name
	dialog.file_selected.connect(callback)
	dialog.show()
	return dialog
