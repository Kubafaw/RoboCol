extends Node

# All reosurces ids
enum possible_resources{Logs = 0, Rock_pile = 1}

# Resources [number : name]
var Resources : Dictionary[int, String] = {
	possible_resources.Logs : "Logs",
	possible_resources.Rock_pile : "Rock_pile",
}

# Categories of industries
enum categories{All = 0, Carpentry = 1, Masonary = 2, Pottery = 3}

# Resource categories [number : category]
var Resource_categories : Dictionary[int, int] = {
	possible_resources.Logs : categories.Carpentry,
	possible_resources.Rock_pile : categories.Masonary,
}

# Drops [name : graphic] 
var Drops : Dictionary[int, Texture] = {
	possible_resources.Logs : load("res://Graphics/Logs.png"),
	possible_resources.Rock_pile : load("res://Graphics/Rock_pile.png"),
}

# All possible nodes ids
enum possible_nodes{Pine_tree = 0, Boulder = 1}

# Nodes resource data
var Nodes : Dictionary[int, ResourceNodeData] = {
	possible_nodes.Pine_tree : load("res://Resources/Nodes/Resources/PineTree.tres"),
	possible_nodes.Boulder : load("res://Resources/Nodes/Resources/Boulder.tres"),
}
