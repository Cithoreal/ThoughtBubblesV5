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
var file_manager : FileManager

func _enter_tree():
    file_manager = get_child(0)
#data is dictionary
func save(data_dict: Dictionary):
    var save_dict = {
        "@id": data_dict["ThoughtBubble"],
        "@context": "/home/cithoreal/ThoughtBubbles/vocab/tb#",
        "data": data_dict["ThoughtBubble"],#text or link
       # "isLink": "", #probably worth making this explicit, but only needs to be included when true
        "lastUpdated": data_dict["Timestamp"],
        "LinkTo": []
    }
    var timestamp_dict: Dictionary = {
        "@id": "Timestamp-[%s]" % [data_dict["Timestamp"]],
        "@context": "/home/cithoreal/ThoughtBubbles/vocab/timestamp#",
        "data": data_dict["Timestamp"],
        "lastUpdated": data_dict["Timestamp"],
        "LinkTo": ["Thoughts/"+save_dict["@id"]]
    } 
    #print(save_dict)
    #region Position
    if data_dict.has("Position"):  #Load latest position and see if it's different, don't update lastUpdated if it's the same
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
        
        timestamp_dict["LinkTo"].append("Thoughts/"+position_dict["@id"])
        timestamp_dict["LinkTo"].append("Thoughts/"+x_dict["@id"])
        timestamp_dict["LinkTo"].append("Thoughts/"+y_dict["@id"])
        timestamp_dict["LinkTo"].append("Thoughts/"+z_dict["@id"])
        timestamp_dict["LinkTo"].append("Positions/"+xpos_dict["@id"])
        timestamp_dict["LinkTo"].append("Positions/"+ypos_dict["@id"])
        timestamp_dict["LinkTo"].append("Positions/"+zpos_dict["@id"])
        position_dict["LinkTo"].append("Thoughts/"+x_dict["@id"])
        position_dict["LinkTo"].append("Thoughts/"+y_dict["@id"])
        position_dict["LinkTo"].append("Thoughts/"+z_dict["@id"])
        position_dict["LinkTo"].append("Thoughts/"+xpos_dict["@id"])
        position_dict["LinkTo"].append("Thoughts/"+ypos_dict["@id"])
        position_dict["LinkTo"].append("Thoughts/"+zpos_dict["@id"])
        position_dict["LinkTo"].append("Thoughts/"+save_dict["@id"])
        x_dict["LinkTo"].append("Positions/"+xpos_dict["@id"])
        y_dict["LinkTo"].append("Positions/"+ypos_dict["@id"])
        z_dict["LinkTo"].append("Positions/"+zpos_dict["@id"])
        x_dict["LinkTo"].append("Thoughts/"+save_dict["@id"])
        y_dict["LinkTo"].append("Thoughts/"+save_dict["@id"])
        z_dict["LinkTo"].append("Thoughts/"+save_dict["@id"])


        file_manager.save_jsonld(position_dict, "Thoughts")
        file_manager.save_jsonld(x_dict, "Thoughts")
        file_manager.save_jsonld(y_dict, "Thoughts")
        file_manager.save_jsonld(z_dict, "Thoughts")
        file_manager.save_jsonld(xpos_dict, "Positions")
        file_manager.save_jsonld(ypos_dict, "Positions")
        file_manager.save_jsonld(zpos_dict, "Positions")


    #endregion

    file_manager.save_jsonld(timestamp_dict, "Thoughts")
    file_manager.save_jsonld(save_dict, "Thoughts")
    
    # data - necessary
    # context - necessary
    # position -optional
    # color - optional
    # 

func load(thought_id, timestamp, load_array):

    print(thought_id, timestamp, load_array)
    var links=file_manager.load_jsonld("Timestamp-[%s]" % timestamp)
    return #file_manager.load_jsonld(load_array)

func get_latest_timestamp(thought_id: String):
    return file_manager.get_latest_timestamp(thought_id)