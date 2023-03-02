tool
extends Spatial

#Bubble properties
export(Color) var bubble_color = Color(0.329412, 0.517647, 0.6, 0.533333)
export(bool) var set_color setget _on_set_color
export(String) var new_thought
export(bool) var link_new_thought setget _on_new_thought_button

export(bool) var focus_thought setget _on_focus_thought
export(bool) var minimize_thought setget _on_minimize_thought
export(bool) var hide_thought setget _on_hide_thought
#Space properties
export(bool) var load_space setget _on_load_space
export(bool) var save_space setget _on_save_thoughts
export(bool) var clear_space setget _on_clear_space

export(bool) var is_focused

export(bool) var run_functions = false

export(Array, String) var hidden_thoughts  

var timestamp_list = []
var timestamp_selector = 1 setget _set_timestamp
export var current_timestamp = ""

func _get_property_list():
	var properties = []
	# Same as "export(int) var timestamp_selector"
	properties.append({
		name = "timestamp_selector",
		type = TYPE_INT,
		hint = 1,
		hint_string = "1," + str(len(timestamp_list))
	})
	return properties

func _set_timestamp(_value):
	get_child(2).load_timestamps()
	current_timestamp = len(timestamp_list)
	#print(_value)
	timestamp_selector = _value
	if (len(timestamp_list) > 0):
		current_timestamp = str(timestamp_list[_value - 1])
		#print(current_timestamp)
		

#export()
#export(bool) var load_links setget load_link_nodes

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
			get_child(1).get_node("Focus").call_deferred("focus")
			print("Focusing " + get_name())
			#print("Iterate through child thoughts and intance them into sub space")
			#print("If child thought belongs only to the focused context, remove it elsewhere")
			#print("else if child thought belongs elsewhere in the space, leave it")
			print("Load properties within the |Focused| |True| context")
			#also add the condition of |Focused| |False| otherwise
		else:
			get_child(1).get_node("Focus").unfocus()
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
			get_child(1).get_node("Linking").new_linked_thought(new_thought)

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
	get_child(1).get_node("Focus").check_context()

