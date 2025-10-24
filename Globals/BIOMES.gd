extends Node

var biome_tile : Dictionary[String, int] = {
	"forest" : 0,
	"clayland" : 2,
	"mountain" : 1
}

var biome_resource_nodes : Dictionary[String, Array] = {
	"forest" : [load("res://ResourceNodes/Pine_tree_node.tscn"), 
	load("res://ResourceNodes/Berry_bush_node.tscn")],
	"clayland" : [],
	"mountain" : [load("res://ResourceNodes/Boulder_node.tscn")]
}
