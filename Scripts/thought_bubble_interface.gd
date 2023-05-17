@tool
class_name thought_bubbles_interface
extends Node3D

#Bubble properties
@export var bubble_color: Color = Color(0.329412, 0.517647, 0.6, 0.533333) : set = _on_set_color
#@export var set_color: bool : set = _on_set_color
@export_enum("Sphere", "Cube", "Cylinder") var shape = 0 : set = _set_shape
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

@export var timestamp_selector: int : set = _set_timestamp
@export var current_timestamp = ""

@export var test: bool : set = test_stuff
@export var test_var = ""
func _enter_tree():
	get_child(0).set_thought(get_name())
	run_functions = true

func _on_renamed():
	get_child(0).set_thought(get_name())




func _on_set_color(_value):
	if (run_functions):
		bubble_color = _value
		get_child(1).set_color(bubble_color)
	
func _set_shape(_value):
	if(run_functions):
		shape = _value
		get_child(1).set_shape(shape)
		
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

func _set_timestamp(_value):
	timestamp_selector = _value
	current_timestamp = get_child(2).load_timestamps(_value)
	#print(current_timestamp)
	

func load_focus_context():
	print("Probably in bubble")

func check_context():
	get_child(1).check_context()
	
func get_child_thoughts():
	return get_child(1).get_child_thoughts()

func test_stuff(_value):
	pass
	
func unselect():
	pass
#	if (!is_focused):
#		print(name, " saving")
#		get_child(2).save()
	

