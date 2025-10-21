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
var file_manager : FileManager

func _enter_tree():
    file_manager = get_child(0)
#data is dictionary
func save(data_dict):

    var save_dict = {
        "@id": data_dict["ThoughtBubble"],
        "@context": "linktothoughtcontext",
        "data": data_dict["ThoughtBubble"],#text or link
       # "isLink": "", #probably worth making this explicit, but only needs to be included when true
        "lastUpdated": data_dict["Timestamp"]
    }
    #print(save_dict)
    file_manager.save_jsonld(save_dict)
    # data - necesary
    # context - necesary
    # position -optional
    # color - optional
    # 

func _save_thought():
    pass

func _save_metadata(metadata):
    pass