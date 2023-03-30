@tool
extends Node3D

#Bubble properties
@export var bubble_color: Color = Color(0.329412, 0.517647, 0.6, 0.533333)
@export var set_color: bool : set = _on_set_color
@export var new_thought: String
@export var link_new_thought: bool : set = _on_new_thought_button

@export var focus_thought: bool : set = _on_focus_thought
@export var minimize_thought: bool : set = _on_minimize_thought
@export var hide_thought: bool : set = _on_hide_thought
#Space properties
@export var load_space: bool : set = _on_load_space
@export var save_space: bool : set = _on_save_thoughts
@export var clear_space: bool : set = _on_clear_space

@export var is_focused: bool

@export var run_functions: bool = false

@export var hidden_thoughts : Array[String]

var timestamp_list = []
@export var timestamp_selector = 1 
@export var current_timestamp = ""
@export var set_timestamp: bool : set = _set_timestamp

#func _get_property_list():
#	var properties = []
#	# Same as "export var timestamp_selector: int"
#	properties.append({
#		name = "timestamp_selector",
#		type = TYPE_INT,
#		hint = 1,
#		hint_string = "1," + str(len(timestamp_list))
#	})
#	return properties

func _set_timestamp(_value):
	current_timestamp = get_child(2).load_timestamps(timestamp_selector)
	print(current_timestamp)
	#current_timestamp = len(timestamp_list)
	#print(_value)
	#timestamp_selector = _value
	#if (len(timestamp_list) > 0):
	#	current_timestamp = str(timestamp_list[_value - 1])
		#print(current_timestamp)
		

#export()
#export var load_links: bool : set = load_link_nodes

func _enter_tree():
	get_child(0).set_thought(get_name())
	run_functions = true

func _on_renamed():
	get_child(0).set_thought(get_name())

func _on_focus_thought(_value):
	if (run_functions):
		#print(str(Time.get_time_string_from_system()) + ": Starting Load")
		is_focused = !is_focused
		if (is_focused):
			get_child(1).focus()
			print("Focusing " + get_name())
			#print("Iterate through child thoughts and intance them into sub space")
			#print("If child thought belongs only to the focused context, remove it elsewhere")
			#print("else if child thought belongs elsewhere in the space, leave it")
			print("Load properties within the |Focused| |True| context")
			#also add the condition of |Focused| |False| otherwise
		else:
			get_child(1).unfocus()
			print("Clear thought space")
			print("iterate through all child thoughts and enable them where applicable")

func _on_minimize_thought(_value):
	
	pass

func _on_hide_thought(_value):
	pass

func _on_load_space(_value):
	if (run_functions):
		#print(str(Time.get_time_string_from_system()) + ": Starting Load")
		get_child(2).load_space()

func _on_set_color(_value):
	if (run_functions):
		get_child(1).set_color(bubble_color)
	

func _on_save_thoughts(_value):
	if (run_functions):
		get_child(2).save()

func _on_new_thought_button(_value):
	if (run_functions && new_thought != ""):
		if (is_focused):
			get_child(2).new_thought_in_space(new_thought)
		else:
			get_child(1).new_linked_thought(new_thought)

func _on_clear_space(_value):
	if (run_functions):
		get_child(2).clear_scene()
	
func initialize():
	get_child(1).initialize()
	
func load_timestamps(timestamps):
	#timestamp_list.append_array(timestamps)
	timestamp_list.clear()
	
	for i in timestamps:
		#print(i)
		timestamp_list.append(i)

func load_focus_context():
	print("Probably in bubble")

func check_context():
	get_child(1).check_context()
	
func get_child_thoughts():
	return get_child(1).get_child_thoughts()

