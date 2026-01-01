extends VBoxContainer

const card_tscn := preload('res://Scenes/Die now/card.tscn')

@onready var tree = get_tree()
@onready var file_menu_popup:PopupMenu = %File.get_popup()
@onready var add_process_menu_popup:PopupMenu = %'Add process'.get_popup()
var current_processes:Array[WindowsProcess] = []


class WindowsProcess:
	var path: String
	var pid: int
	var name: String


	@warning_ignore('shadowed_variable')
	func _init(path:String, pid:int, name:String) -> void:
		self.path = path
		self.pid = pid
		self.name = name


	func kill() -> void:
		if pid == -1: return # Do nothing if placeholder PID.
		OS.kill(pid)
		pid = -1




## Returns whether or not the function succeeded.
func refresh_process_list() -> bool:
	# Clear process lists.
	current_processes.clear()
	add_process_menu_popup.clear(true)

	# Retrieve text output from windows "wmic process get" command.
	var wmic_output:Array[String] = []
	var exit_code:int = OS.execute('CMD.exe', PackedStringArray(['/C','wmic process get ProcessId, name, ExecutablePath /FORMAT:LIST']), wmic_output)
	if exit_code == -1:
		return false
	
	# Parse text into useable data.
	var processes:PackedStringArray = wmic_output[0].split('\r\r\n\r\r\n\r\r\n', false) # Split into individual blocks. Sidenote: the way Windows outputs newlines using a hundred \r\n characters is fucking absurd.
	for process_info:String in processes:
		if process_info.begins_with('\r'): continue
		var split_process_info := process_info.split('\r\r\n', false) # Split each section of the block.
		# Extract only useful text from each block.
		var process_path:String = split_process_info[0].replace('ExecutablePath=','')
		var process_name:String = split_process_info[1].replace('Name=','')
		var process_id := int(split_process_info[2].replace('ProcessId=',''))
		# Add parsed process to process list.
		current_processes.append(WindowsProcess.new(process_path, process_id, process_name))

	# Sort process list alphabetically.
	current_processes.sort_custom(func(a,b) -> bool:
		return a.name < b.name
	)
	# Add processes to menu.
	for process in current_processes:
		add_process_menu_popup.add_item(process.name+'   '+str(process.pid))

	# Update cards.
	for card:Control in %'Process Cards'.get_children():
		var active:bool = false
		var new_process:WindowsProcess = card.process
		for process in current_processes:
			if card.process.path == process.path:
				active = true
				new_process = process
		card.update(new_process, active)

	return true


func add_process_card(process:WindowsProcess) -> void:
	var card := card_tscn.instantiate()
	card.update(process, true)
	%'Process Cards'.add_child(card)




# File functions.
# --------------

func save_file() -> void:
	var file_dialog := FileDialog.new()
	file_dialog.title = 'Save your process killer script'
	file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.add_filter('*.bat')
	file_dialog.current_file = 'new_process_killer.bat'
	file_dialog.file_selected.connect(_save_file)
	file_dialog.use_native_dialog = true
	file_dialog.force_native = true
	file_dialog.min_size = Vector2i(175, 100)
	file_dialog.show()


func _save_file(path:String) -> void:
	var commands := PackedStringArray()
	for card:Control in %'Process Cards'.get_children():
		commands.append('taskkill /f /im "'+card.process.name+'"')

	var script = '@echo off\n' + '\n'.join(commands)
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(script)
	file.close()


func load_file() -> void:
	var file_dialog := FileDialog.new()
	file_dialog.title = 'Load a custom ID generator'
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.add_filter('*.json')
	file_dialog.file_selected.connect(_load_file)
	file_dialog.use_native_dialog = true
	file_dialog.force_native = true
	file_dialog.min_size = Vector2i(175, 100)
	file_dialog.show()


func _load_file(path:String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	var text := file.get_as_text()
	file.close()

	var lines := text.split('\n')
	for line in lines:
		pass




# Callbacks.
# ----------

func _ready() -> void:
	file_menu_popup.id_pressed.connect(_file_menu_button_pressed)
	add_process_menu_popup.id_pressed.connect(_add_process_menu_button_pressed)
	refresh_process_list()


func _process(_delta:float) -> void:
	if Input.is_action_just_pressed('ctrl-s'):
		save_file()
	if Input.is_action_just_pressed('ctrl-l'):
		load_file()


func _file_menu_button_pressed(id:int) -> void:
	match id:
		0: save_file()
		1: load_file()


func _add_process_menu_button_pressed(id:int) -> void:
	var process = current_processes.get(id)
	if process is not WindowsProcess:
		return
	add_process_card(process)


func _on_home_pressed() -> void:
	tree.change_scene_to_file('res://Scenes/Home/home.tscn')


func _on_refresh_pressed() -> void:
	refresh_process_list()



func _on_kill_all_pressed() -> void:
	for card:Control in %'Process Cards'.get_children():
		card._on_kill_pressed()
