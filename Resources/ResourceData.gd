extends Node

enum possible_resources{Logs = 0, Rock_pile = 1}

# Resources [number : name]
var Resources : Dictionary[int, String] = {
	0 : "Logs",
	1 : "Rock_pile",
}

# Drops [name : graphic] 
var Drops : Dictionary[String, Texture] = {
	"Logs" : load("res://Graphics/Logs.png"),
	"Rock_pile" : load("res://Graphics/Rock_pile.png"),
	"Berries" : load("res://Graphics/Berries.png"),
	"Sticks" : load("res://Graphics/Sticks.png"),
}

# Nodes: [Texture, GatherTime, Drop, DropAmount, size]
var Nodes : Dictionary[String, Array] = {
	"Pine_tree" : [load("res://Graphics/Pine_tree.png"), 1.0, "Logs", 3, Vector2i(1, 1)],
	"Berry_bush" : [load("res://Graphics/Berry_bush.png"), 1.0, "Berries", 3, Vector2i(1, 1)],
	"Berry_bush_harvested" : [load("res://Graphics/Berry_bush_harvested.png"), 1.0, "Sticks", 3, Vector2i(1, 1)],
	"Boulder" : [load("res://Graphics/Boulder.png"), 1.0, "Rock_pile", 3, Vector2i(1, 1)],
}
