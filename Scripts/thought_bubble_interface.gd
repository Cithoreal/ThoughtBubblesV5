tool
extends Spatial

#Bubble properties
export(Color) var bubble_color = Color(0.329412, 0.517647, 0.6, 0.533333)
export(bool) var set_color setget _on_set_color
export(String) var new_thought
export(bool) var link_new_thought setget _on_new_thought_button


#Space properties
export(bool) var load_space setget _on_load_space
export(bool) var save_space setget _on_save_thoughts

export(bool) var is_focused

export(bool) var run_functions = false

#var timestamp_list = [1.2412, 41.2312, 151.1123]
#var my_property = 1 setget _set_timestamp
#export var current_timestamp = ""

#func _get_property_list():
#	var properties = []
	# Same as "export(int) var my_property"
#	properties.append({
#		name = "my_property",
#		type = TYPE_INT,
#		hint = 1,
#		hint_string = "0," + str(len(timestamp_list))
#	})
#	return properties

#func _set_timestamp(_value):
#	#print(_value)
#	current_timestamp = str(timestamp_list[_value])

#export()
#export(bool) var load_links setget load_link_nodes

func _enter_tree():
	get_child(0).set_thought(get_name())

func _on_renamed():
	get_child(0).set_thought(get_name())

func _on_load_space(_value):
	if (run_functions):
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
			get_child(2).create_and_link_new_thought(new_thought)
		else:
			get_child(1).create_new_thought(new_thought)
			
func initialize():
	get_child(1).initialize()
