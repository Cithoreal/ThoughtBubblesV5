@tool
extends Node


class_name ThoughtBubbleStore

# intermediate step between bubble and filemanager
# should abstract logic and make it feature rich

# thoughtbubbles should be expandable and collapsable in data
# all relevant properties can be expanded to their own thoughts and be used to link and reference all other thoughtbubbles that share them
# properties should also be able to be collapsed down into a jsonld file to limit the total number of thoughts and links

#thoughtbubbles can be stored in an ndjson file or in a jsonld graph, being able to collapse to one file is useful for networking
#thoughtbubbles can also be expanded out to individual jsonld files that all link to each other, this is useful for interchangability
# and atomic work

# to start with, I will work on the fully expanded approach and an ndjson log
# can also automatically commit changes to a git repo for backup and version history

#each node neds an @context from an online or local semantic definition

# current space should contain an "address path" ordered context breadcrumb trail so when a thoughtbubble is updated, the whole context can recieve a 
#latest update timestamp

#a bubble looking to save a value should pass its own id and property to update and the whole context trail

#for some more arbitrary/artful ideas, specific categories of properties can be in their own files for my own sanity and ease of organization
# for example, a positions.ndjson, colors.ndjson, timestamps.ndjson, and bubbles.ndjson, 
# or thoughtbubbles themselves can exist as individual files with properties/metadata condensed into their own files

#recieve data dictionary, break it down and categorize known properties/metadata

#clear out links to positions and values that are commited to a git memory to keep current graphs lean
var file_manager: FileManager
var sets

func _enter_tree():
    file_manager = get_child(0)
    sets = get_child(1)
#data is dictionary
func save(data_dict: Dictionary):
    var save_dict = {
        "@id": data_dict["ThoughtBubble"],
        "@context": "/home/cithoreal/ThoughtBubbles/vocab/tb#",
        "data": data_dict["ThoughtBubble"], # text or link
       # "isLink": "", #probably worth making this explicit, but only needs to be included when true
        "lastUpdated": data_dict["Timestamp"],
        "LinkTo": []
    }
    var timestamp_dict: Dictionary = {
        "@id": "Timestamp-[%s]" % [data_dict["Timestamp"]],
        "@context": "/home/cithoreal/ThoughtBubbles/vocab/timestamp#",
        "data": data_dict["Timestamp"],
        "lastUpdated": data_dict["Timestamp"],
        "LinkTo": [save_dict["@id"]]
    }
    #print(save_dict)
    #region Position
    if data_dict.has("Position"): # Load latest position and see if it's different, don't update lastUpdated if it's the same
        var position_dict: Dictionary = {
            "@id": "Position-[%s]" % [", ".join(data_dict["Position"])],
            "@context": "/home/cithoreal/ThoughtBubbles/vocab/position#",
            "data": ", ".join(data_dict["Position"]),
            "lastUpdated": data_dict["Timestamp"],
            "LinkTo": []
        }
        var x_dict: Dictionary = {
            "@id": "x-pos",
            "@context": "/home/cithoreal/ThoughtBubbles/vocab/tb#",
            "data": "x-pos",
            "lastUpdated": data_dict["Timestamp"],
            "LinkTo": []
        }
        var y_dict: Dictionary = {
            "@id": "y-pos",
            "@context": "/home/cithoreal/ThoughtBubbles/vocab/tb#",
            "data": "y-pos",
            "lastUpdated": data_dict["Timestamp"],
            "LinkTo": []
        }
        var z_dict: Dictionary = {
            "@id": "z-pos",
            "@context": "/home/cithoreal/ThoughtBubbles/vocab/tb#",
            "data": "z-pos",
            "lastUpdated": data_dict["Timestamp"],
            "LinkTo": []
        }

        var xpos_dict: Dictionary = {
            "@id": data_dict["x"],
            "@context": "/home/cithoreal/ThoughtBubbles/vocab/tb#",
            "data": data_dict["x"],
            "lastUpdated": data_dict["Timestamp"],
            "LinkTo": []

        }

        var ypos_dict: Dictionary = {
            "@id": data_dict["y"],
            "@context": "/home/cithoreal/ThoughtBubbles/vocab/tb#",
            "data": data_dict["y"],
            "lastUpdated": data_dict["Timestamp"],
            "LinkTo": []

        }

        var zpos_dict: Dictionary = {
            "@id": data_dict["z"],
            "@context": "/home/cithoreal/ThoughtBubbles/vocab/tb#",
            "data": data_dict["z"],
            "lastUpdated": data_dict["Timestamp"],
            "LinkTo": []
        }
        
        timestamp_dict["LinkTo"].append(position_dict["@id"])
        timestamp_dict["LinkTo"].append(x_dict["@id"])
        timestamp_dict["LinkTo"].append(y_dict["@id"])
        timestamp_dict["LinkTo"].append(z_dict["@id"])
        timestamp_dict["LinkTo"].append(xpos_dict["@id"])
        timestamp_dict["LinkTo"].append(ypos_dict["@id"])
        timestamp_dict["LinkTo"].append(zpos_dict["@id"])
        position_dict["LinkTo"].append(x_dict["@id"])
        position_dict["LinkTo"].append(y_dict["@id"])
        position_dict["LinkTo"].append(z_dict["@id"])
        position_dict["LinkTo"].append(xpos_dict["@id"])
        position_dict["LinkTo"].append(ypos_dict["@id"])
        position_dict["LinkTo"].append(zpos_dict["@id"])
        position_dict["LinkTo"].append(save_dict["@id"])
        x_dict["LinkTo"].append(xpos_dict["@id"])
        y_dict["LinkTo"].append(ypos_dict["@id"])
        z_dict["LinkTo"].append(zpos_dict["@id"])
        x_dict["LinkTo"].append(save_dict["@id"])
        y_dict["LinkTo"].append(save_dict["@id"])
        z_dict["LinkTo"].append(save_dict["@id"])


        file_manager.save_jsonld(position_dict)
        file_manager.save_jsonld(x_dict)
        file_manager.save_jsonld(y_dict)
        file_manager.save_jsonld(z_dict)
        file_manager.save_jsonld(xpos_dict)
        file_manager.save_jsonld(ypos_dict)
        file_manager.save_jsonld(zpos_dict)


    #endregion

    file_manager.save_jsonld(timestamp_dict)
    file_manager.save_jsonld(save_dict)
    
    # data - necessary
    # context - necessary
    # position -optional
    # color - optional
    # 

func load_data(thought_id, timestamp, load_array):
    print("LOAD DATA START")
    #print(thought_id, timestamp, load_array)
    var data_at_timestamp = file_manager.load_jsonld("Timestamp-[%s]" % timestamp)
    var data_output = data_at_timestamp["LinkTo"]
   # print("tbs 162 - data_output", data_output)
    #print("tbs 163 - out[linkTo[", data_output)
    for property in load_array:
        var out = file_manager.load_jsonld(property)
        print("tbs 167 - property: ", property)
        print("tbs 168 - intersect1: ", data_output)
        print("tbs 169 - intersect2: ", out["LinkTo"])
        data_output = sets.IntersectArrays(data_output, out["LinkTo"])
       
    
    print("tbs 167 - data output: ", data_output)
    if data_output.has(thought_id):
        data_output.remove_at(data_output.find(thought_id))
    #if len(data_output)>0:
       # load_data(thought_id, timestamp, data_output)
    print("LOAD DATA END")
    return data_output[0]

func get_latest_timestamp(thought_id: String):
    return file_manager.get_latest_timestamp(thought_id)

#region load_properties

func get_bubble_property(thought_id, timestamp, property_array): # TODO Rewrite this to not reference specific loading procedures
    var output = []
    var load_array = [] # , loaded_nodes["`"+property+"`"], loaded_nodes["`"+element+"`"], loaded_nodes["`Timestamp`"]]
    load_array.append_array(property_array)
    #load_array.append("Timestamp")
    output = load_data(thought_id, timestamp, load_array)
    print("tbs 186 - bubble properties %s" % output)
    return output
    #var back_timestamps = thoughtbubble_store.get_from_orbitdb([timestamp], "`BackLink`")
    #print(back_timestamps)

    if (!output.has(timestamp)):
        #Ensure this is the closest timestamp to the selected as possible
        for time in output:
            if (float(time) < float(timestamp)):
                timestamp = time
    #print(output)		
    #print(timestamp)	
    if (output.find(timestamp) > -1):
        load_array.pop_back()
        load_array.append(str(timestamp))
        #load_array = [loaded_nodes[bubble_interface_node.get_name()], loaded_nodes["`" + property + "`"], loaded_nodes["`" + element + "`"], loaded_nodes[str(timestamp)]]
        #print(load_array)
       # output = thoughtbubble_store.get_from_orbitdb(load_array)
        if (output.has(str(timestamp))):
            output.remove_at(output.find(str(timestamp)))
        if (len(output) > 0):
            return output
        else:
            return null
    else:
        print("Remember to set the timestamp")
        #bubble_interface_node.visible = false


func load_position_x(thought_id, timestamp):
    timestamp = str(timestamp)
    var x = ""
    x = get_bubble_property(thought_id, timestamp, ["x-pos"])
    print("X: ",x)

    return x

func load_position(thought_id, timestamp):
    timestamp = str(timestamp)
    var x = ""
    var y = ""
    var z = ""
    print(thought_id + " loading position")
    x = get_bubble_property(thought_id, timestamp, ["x-pos"])
    y = get_bubble_property(thought_id, timestamp, ["y-pos"])
    z = get_bubble_property(thought_id, timestamp, ["z-pos"])
    # don't update a position if the value is null

    print(x,",",y,",",z)
    if typeof(x) != null:
        x = x[len(x) - 1]
    if typeof(y) != null:
        y = y[len(y) - 1]
    if typeof(z) != null:
        z = z[len(z) - 1]

    #print(x,",",y,",",z)
    #print(x)
    #print(bubble_interface_node.get_name() + ": " + str(Vector3(float(x),float(y),float(z))))
    if (x == ""):
        x = 0
    if (y == ""):
        y = 0
    if (z == ""):
        z = 0
    #print(Vector3(float(x),float(y),float(z)))
    return Vector3(float(x), float(y), float(z))
    

func load_color(thought_id, timestamp):
    var r = ""
    var g = ""
    var b = ""
    var a = ""

    r = get_bubble_property(thought_id, timestamp, ["`Color`", "`r`"])
    g = get_bubble_property(thought_id, timestamp, ["`Color`", "`g`"])
    b = get_bubble_property(thought_id, timestamp, ["`Color`", "`b`"])
    a = get_bubble_property(thought_id, timestamp, ["`Color`", "`a`"])
    r = r[len(r) - 1]
    g = g[len(g) - 1]
    b = b[len(b) - 1]
    a = a[len(a) - 1]
    if (r == "" || g == "" || b == "" || a == ""):
        return Color(0.329412, 0.517647, 0.6, 0.533333)

    else:
        r = float(r)
        g = float(g)
        b = float(b)
        a = float(a)
        return Color(r, g, b, a)



func load_shape(thought_id, timestamp):
    timestamp = str(timestamp)
    var shape = get_bubble_property(thought_id, timestamp, ["`Shape`"])
    shape = shape[len(shape) - 1]
    var shape_id = 0
    match shape:
        "CSGSphere3D":
            shape_id = 0
        "CSGBox3D":
            shape_id = 1
        "CSGCylinder3D":
            shape_id = 2
    return shape_id
    
    




#endregion