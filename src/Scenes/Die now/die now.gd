extends VBoxContainer

const card_tscn := preload('res://Scenes/Die now/card.tscn')
const comment_card_tscn := preload("res://Scenes/Die now/comment_card.tscn")

@onready var tree = get_tree()
@onready var file_menu_popup:PopupMenu = %File.get_popup()
@onready var flags_menu_popup:PopupMenu = %Flags.get_popup()
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


	## Returns "-1" if failed.
	func kill(forceful:bool=false) -> int:
		if pid == -1: return -1 # Return if placeholder PID.
		var f_flag := ' /f' if forceful else ''
		var exit_code:int = OS.execute('CMD.exe', PackedStringArray(['/C', 'taskkill /pid '+str(pid)+f_flag]))
		if exit_code != -1: pid = -1
		return exit_code




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
		if card.card_type != &'process': continue
		var active:bool = false
		var new_process:WindowsProcess = card.process
		for process in current_processes:
			if not card.process.path.is_empty() && card.process.path == process.path:
				active = true
				new_process = process
		card.update(new_process, active)

	return true


func add_process_card(process:WindowsProcess, process_running:bool=true, flags:Array[bool]=[]) -> void:
	var card := card_tscn.instantiate()
	%'Process Cards'.add_child(card)
	card.update(process, process_running)
	var index:int = -1
	for flag:bool in flags:
		index += 1
		card.set_property(index, flag)


func add_comment_card(text:String='') -> void:
	var card := comment_card_tscn.instantiate()
	%'Process Cards'.add_child(card)
	card.set_text(text)




# File functions.
# --------------

func save_file() -> void:
	PopupTool.popup_file_save('Save your process killer script', PackedStringArray(['*.bat']), 'new_process_killer.bat', _save_file)


func _save_file(path:String) -> void:
	var commands := PackedStringArray()
	for card:Control in %'Process Cards'.get_children():
		# Add taskkill command.
		if card.card_type == &'process':
			var f_flag := ' /f' if card.forceful else ''
			commands.append('taskkill /im "'+card.process.name+'" /t' + f_flag + ' &::'+card.process.path)
		# Add comment.
		elif card.card_type == &'comment':
			if card.text.is_empty(): commands.append('')
			else: commands.append(':: '+card.text)

	var script = '@echo off\n' + '\n'.join(commands)
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(script)
	file.close()


func load_file() -> void:
	PopupTool.popup_file_load('Load a custom ID generator', PackedStringArray(['*.bat']), _load_file)


func _load_file(path:String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	var text := file.get_as_text()
	file.close()

	var lines := text.split('\n', true)
	for line in lines:
		# Add comment card.
		if line == '' or line.begins_with('::'):
			add_comment_card(line.trim_prefix(':: ').trim_prefix('::'))
			continue
		# Add process card.
		if not line.begins_with('taskkill /im'): continue
		var process_name:String = line.split('"')[1]
		var command_and_flags = line.split('&::')[0].replace('"'+process_name+'"','').split(' ', false)
		var process_path:String = line.split('&::', false).get(1)
		var f_flag:bool = command_and_flags.has('/f')
		var t_flag:bool = command_and_flags.has('/t')
		add_process_card(WindowsProcess.new(process_path, -1, process_name), false, [f_flag, t_flag])

	refresh_process_list()




# Callbacks.
# ----------

func _ready() -> void:
	file_menu_popup.id_pressed.connect(_file_menu_button_pressed)
	flags_menu_popup.id_pressed.connect(_flags_menu_button_pressed)
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


func _flags_menu_button_pressed(id:int) -> void:
	var is_item_checked:bool = flags_menu_popup.is_item_checked(id)
	flags_menu_popup.set_item_checked(id, not is_item_checked)
	for card:Control in %'Process Cards'.get_children():
		card.set_property(id, not is_item_checked)


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
		if card.card_type != &'process': continue
		card._on_kill_pressed()


func _on_forceful_all_toggled(toggled_on: bool) -> void:
	for card:Control in %'Process Cards'.get_children():
		if card.card_type != &'process': continue
		card.update(card.process, card.process_running, toggled_on)


func _on_add_comment_pressed() -> void:
	add_comment_card()
