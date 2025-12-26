extends VBoxContainer

const default_character_map:Dictionary[String,Array] = {
	'a':['b','c','d','f','g','i','k','l','m','n','p','r','s','t','v','w','x','z'],
	'b':['a','e','i','l','o','r','u','y'],
	'c':['a','e','i','l','o','r','u','y'],
	'd':['a','e','i','l','o','r','u','y'],
	'e':['a','b','c','d','f','g','h','k','l','m','n','p','q','r','s','t','v','w','x','y','z'],
	'f':['a','e','i','l','o','r','u','y'],
	'g':['a','e','h','i','l','n','o','r','u','w','y'],
	'h':['a','e','i','l','o','r','u','y'],
	'i':['a','b','c','d','f','g','k','l','m','n','p','q','r','s','t','v','w','x','y','z'],
	'j':['a','e','h','i','o','u','y'],
	'k':['a','e','i','l','o','r','u','y'],
	'l':['a','b','d','e','f','g','i','k','m','o','p','r','t','u','y'],
	'm':['a','e','i','o','u','y'],
	'n':['a','d','e','g','h','i','k','o','u','y'],
	'o':['b','c','d','f','g','h','i','j','k','l','m','n','p','q','r','s','t','u','v','w','x','y','z'],
	'p':['a','e','i','l','o','r','u','y'],
	'q':['u'],
	'r':['a','e','i','o','u','y'],
	's':['a','b','c','e','i','k','l','m','n','o','p','q','t','u','v','w','y'],
	't':['a','e','i','l','o','r','u','y'],
	'u':['a','b','c','d','e','f','g','k','l','m','n','p','q','r','s','t','v','w','x','z'],
	'v':['a','e','i','l','o','r','u','y'],
	'w':['a','e','h','i','l','o','r','u','y'],
	'x':['a','e','i','o','u','y'],
	'y':['a','e','i','o','u'],
	'z':['a','e','i','o','u','y'],
}

var character_map = default_character_map
@onready var tree = get_tree()
@onready var word_count:int = %'Word Count'.value
@onready var word_length:int = %'Word Length'.value
var starter_character:String = ''


func generate() -> PackedStringArray:
	var result := PackedStringArray()
	var choice: String
	var map:Array = character_map.values()
	if starter_character.is_empty():
		choice = random_starter(map)
	else:
		choice = starter_character
	for item in choice: result.append(item)

	var prev = choice[-1]
	for i in range(word_length-1):
		if prev not in character_map.keys():
			result.append('[ERR]')
			prev = random_starter(map)
			continue
		choice = character_map[prev][randi_range(0, character_map[prev].size()-1)]
		result.append(choice)
		prev = choice[-1]

	result[0] = result[0].to_upper()
	return result


func random_starter(map:Array) -> String:
	var subset:Array = map[randi_range(0, map.size()-1)]
	return subset[randi_range(0, subset.size()-1)]


# Callbacks.
# ----------

func _ready() -> void:
	%'Word Length Label'.text = str(word_length) + ' char'


func _process(_delta:float) -> void:
	pass


func _on_home_pressed() -> void:
	tree.change_scene_to_file('res://Scenes/Home/home.tscn')


func _on_word_count_value_changed(value:float) -> void:
	word_count = int(value)


func _on_word_length_value_changed(value:float) -> void:
	word_length = int(value)
	%'Word Length Label'.text = str(word_length) + ' char'


func _on_starter_text_changed(new_text:String) -> void:
	starter_character = new_text


func _on_generate_pressed() -> void:
	var lines := PackedStringArray()
	# Generate words.
	for i in range(word_count):
		lines.append(''.join(generate()))
	# Set output.
	%Output.text = '\n'.join(lines)


func _on_copy_pressed() -> void:
	DisplayServer.clipboard_set(%Output.text)
