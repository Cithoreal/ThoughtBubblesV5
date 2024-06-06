extends Node

class_name node_processor

#func getIntersection(dict):
	##Get the intersection of arrays in the dictionary's values
	#print("getting intersection");
	#var intersection = [];
	## for (keyValues in dictionary.k)
	#for n in range(dict[Object.keys(dict)[0]].length):
		#var value = dict[Object.keys(dict)[0]][n]
		#var exists = true
		#for i in range(1,Object.keys(dict).length):
			#if (!dict[Object.keys(dict)[i]].includes(value)):
				#exists = false
				#break
		#
		#if (exists):
			#intersection.append(value)
	#
	##console.log("intersection: " + intersection)
	#return {"values" : intersection};
  

#func addToDB(thoughts) {
	##console.log("adding to db: " + thoughts);
	#var nodes = [];
	##Check each value to see if it is a file or not
	##Add file conent ids to the value array
	#for (let i = 1; i < thoughts.length; i++) {
	  #nodes.push(thoughts[i]);
	  #if (this.fileExists(thoughts[i])) {
		#console.log("adding file to ipfs");
		#const file = await this.node.add({
		  #path: thoughts[i],
		  #content: fs.createReadStream(thoughts[i]),
		#});
		#await this.node.pin.add(file.cid);
		##console.log(file.cid.toString())
		#nodes.push(thoughts[i].substring(0, thoughts[i].indexOf(".")));
		#nodes.push(thoughts[i].substring(thoughts[i].indexOf(".")));
		#nodes.push(file.cid.toString());
		##console.log(nodes)
	  #}
	#}
	##console.log(nodes)
	#for (let i = 0; i < nodes.length; i++) {
	 ## console.log(nodes[i])
	  #if ((await this.thoughtDictDB.get(nodes[i])) == null) {
	   ## console.log("adding node: " + nodes[i]);
		#await this.thoughtDictDB.put(nodes[i], { values: [] });
	  #}
	#}
#
	#if (thoughts[0] == "-1" || thoughts[0] == "-2") {
	  #for (let i = 0; i < nodes.length; i++) {
		#for (let j = i; j < nodes.length; j++) {
		  #if (i != j) {
			#var node_values = await this.thoughtDictDB.get(nodes[i]).values;
			##console.log(node_values);
			#if (!node_values.includes(nodes[j])) {
			  #node_values.push(nodes[j]);
			#}
			#await this.thoughtDictDB.put(nodes[i], { values: node_values });
		  #}
		#}
	  #}
	#}
	#if (thoughts[0] == "-2") {
	  #for (let i = nodes.length - 1; i >= 0; i--) {
		#for (let j = i; j >= 0; j--) {
		  #if (i != j) {
			#var node_values = await this.thoughtDictDB.get(nodes[i]).values;
			#if (!node_values.includes(nodes[j])) {
			  #node_values.push(nodes[j]);
			#}
			#await this.thoughtDictDB.put(nodes[i], { values: node_values });
		  #}
		#}
	  #}
	#}
	#if (thoughts[0] == "-3") {
	  #for (let i = 0; i < nodes.length; i++) {
		#if (i != nodes.length - 1) {
		  #var node_values = await this.thoughtDictDB.get(nodes[i]).values;
		  #if (!node_values.includes(nodes[i + 1])) {
			#node_values.push(nodes[i + 1]);
		  #}
		  #await this.thoughtDictDB.put(nodes[i], { values: node_values });
		#}
	  #}
	#}
  #}
#
#func getFromDB(thoughts) {
   ## console.log(await this.thoughtDictDB.all)
	##console.log(thoughts);
	#let toString = (obj) =>
	  #Object.entries(obj)
		#.map(([k, v]) => `${k}: ${v}`)
		#.join(", ");
	#var node_dictionary = {};
#
	#for (let i = 1; i < thoughts.length; i++) {
	  #if ((await this.thoughtDictDB.get(thoughts[i])) != null) {
		#node_dictionary[thoughts[i]] = await this.thoughtDictDB.get(thoughts[i])
		  #.values;
	  #} else {
		#node_dictionary[thoughts[i]] = "[]";
	  #}
	#}
#
	#if (thoughts[0] == "-1") {
	  #node_dictionary = this.getIntersection(node_dictionary);
	#}
#
	##console.log(node_dictionary);
	## await this.thoughtDictDB.close();
#
	#return toString(node_dictionary);
  #}


