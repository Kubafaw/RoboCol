extends Node

# All reosurces ids
enum possible_resources{Logs, Rock_pile, Clay, Token,
 ForestryUpgrade, PotteryUpgrade, MiningUpgrade}

# Resources [number : name]
var Resources : Dictionary[int, String] = {
	possible_resources.Logs : "Logs",
	possible_resources.Rock_pile : "Rock_pile",
	possible_resources.Clay : "Clay",
	possible_resources.Token : "Token",
	possible_resources.ForestryUpgrade : "ForestryUpgrade",
	possible_resources.PotteryUpgrade : "PotteryUpgrade",
	possible_resources.MiningUpgrade : "MiningUpgrade"
}

# Categories of industries
enum categories{All = 0, Carpentry = 1, Masonary = 2, Pottery = 3}

# Resource categories [number : category]
var Resource_categories : Dictionary[int, int] = {
	possible_resources.Logs : categories.Carpentry,
	possible_resources.Rock_pile : categories.Masonary,
	possible_resources.Clay : categories.Pottery,
	possible_resources.ForestryUpgrade : categories.Carpentry,
	possible_resources.PotteryUpgrade : categories.Pottery,
	possible_resources.MiningUpgrade : categories.Masonary,
	possible_resources.Token : categories.All
}

# Graphics [name : graphic] 
var Drops : Dictionary[int, Texture] = {
	possible_resources.Logs : load("res://Graphics/Logs.png"),
	possible_resources.Rock_pile : load("res://Graphics/Rock_pile.png"),
	possible_resources.Clay : load("res://Graphics/Rock_pile.png"),
	possible_resources.Token : load("res://Graphics/Logs.png"),
	possible_resources.ForestryUpgrade : load("res://Graphics/Logs.png"),
	possible_resources.PotteryUpgrade : load("res://Graphics/Logs.png"),
	possible_resources.MiningUpgrade : load("res://Graphics/Logs.png")
}

# All possible nodes ids
enum possible_nodes{Pine_tree = 0, Boulder = 1}

# Nodes resource data
var Nodes : Dictionary[int, ResourceNodeData] = {
	possible_nodes.Pine_tree : load("res://Resources/Nodes/Resources/PineTree.tres"),
	possible_nodes.Boulder : load("res://Resources/Nodes/Resources/Boulder.tres"),
}
