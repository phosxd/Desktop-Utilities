extends VBoxContainer


const letters:String = 'abcdefghijklmnopqrstuvwxyz'
const numbers:String = '0123456789'
const symbols:String = './?!@#$%^&*=+:' # Not including every symbol because I don't want the output to be ugly, maybe thats a crazy thing to think...
const unicode_start_index:int = 70 # Past all alphanumeric characters.
const unicode_end_index:int = 297_334 # As of Unicode version 17, there are this many assigned characters however not all are supported in Godot.
const unicode_lite_end_index:int = 50_000

@onready var include_menu_popup:PopupMenu = $HFlow/Include.get_popup()

@onready var part_length := int($'HFlow/Part length'.value)
@onready var prefix:String = $HFlow/Prefix.text
@onready var suffix:String = $HFlow/Suffix.text
@onready var custom_includes:String = $'HFlow/Custom includes'.text
var include_letters := true
var include_capitol_letters := false
var include_numbers := true
var include_symbols := false
var include_unicode_lite := false
var include_unicode_spectrum := false


func set_options(options:Dictionary) -> void:
	part_length = options.get('part_length', part_length)
	prefix = options.get('prefix', prefix)
	suffix = options.get('suffix', suffix)
	custom_includes = options.get('custom_includes', custom_includes)
	$'HFlow/Part length'.value = part_length
	$HFlow/Prefix.text = prefix
	$HFlow/Suffix.text = suffix
	$'HFlow/Custom includes'.text = custom_includes
	include_letters = options.get('include_letters', include_letters)
	include_capitol_letters = options.get('include_capitol_letters', include_capitol_letters)
	include_numbers = options.get('include_numbers', include_numbers)
	include_symbols = options.get('include_symbols', include_symbols)
	include_unicode_lite = options.get('include_unicode_lite', include_unicode_lite)
	include_unicode_spectrum = options.get('include_unicode_spectrum', include_unicode_spectrum)
	include_menu_popup.set_item_checked(0, include_letters)
	include_menu_popup.set_item_checked(1, include_capitol_letters)
	include_menu_popup.set_item_checked(2, include_numbers)
	include_menu_popup.set_item_checked(3, include_symbols)
	include_menu_popup.set_item_checked(4, include_unicode_lite)
	include_menu_popup.set_item_checked(5, include_unicode_spectrum)


func get_options() -> Dictionary[String,Variant]:
	var result:Dictionary[String,Variant] = {
		'part_length': part_length,
		'prefix': prefix,
		'suffix': suffix,
		'custom_includes': custom_includes,
		'include_letters': include_letters,
		'include_capitol_letters': include_capitol_letters,
		'include_numbers': include_numbers,
		'include_symbols': include_symbols,
		'include_unicode_lite': include_unicode_lite,
		'include_unicode_spectrum': include_unicode_spectrum,
	}
	return result


func generate() -> PackedStringArray:
	var result := PackedStringArray()
	result.append(prefix)

	var char_set := Array(custom_includes.split())
	if include_letters: char_set.append_array(letters.split())
	if include_capitol_letters: char_set.append_array(letters.to_upper().split())
	if include_numbers: char_set.append_array(numbers.split())
	if include_symbols: char_set.append_array(symbols.split())

	for i in range(part_length):
		if include_unicode_spectrum:
			result.append(String.chr(randi_range(unicode_start_index, unicode_end_index)))
		elif include_unicode_lite:
			result.append(String.chr(randi_range(unicode_start_index, unicode_lite_end_index)))
		else:
			var choice = char_set.pick_random()
			if choice is not String: continue
			result.append(choice)
	result.append(suffix)
	return result


func toggle_include_property(id:int) -> void:
	var is_item_checked:bool = include_menu_popup.is_item_checked(id)
	include_menu_popup.set_item_checked(id, not is_item_checked)
	match id:
		0: include_letters = not is_item_checked
		1: include_capitol_letters = not is_item_checked
		2: include_numbers = not is_item_checked
		3: include_symbols = not is_item_checked
		4: include_unicode_lite = not is_item_checked
		5: include_unicode_spectrum = not is_item_checked


# Callbacks.
# ----------

func _ready() -> void:
	include_menu_popup.id_pressed.connect(_include_menu_button_pressed)


func _include_menu_button_pressed(id:int) -> void:
	toggle_include_property(id)


func _on_part_length_value_changed(value:float) -> void:
	part_length = int(value)


func _on_prefix_text_changed(new_text: String) -> void:
	prefix = new_text


func _on_suffix_text_changed(new_text:String) -> void:
	suffix = new_text


func _on_custom_includes_text_changed(new_text:String) -> void:
	custom_includes = new_text
