extends Node

# All reosurces ids
enum possible_resources{Clay, Logs, Stones, Planks, StoneBlocks, Bricks, ClayVessels,
	Token, ForestryToken, PotteryToken, MiningToken}

# Categories of industries
enum categories{All = 0, Carpentry = 1, Masonary = 2, Pottery = 3}

# Resources [number : [name, category]]
var Resources : Dictionary[int, ResourceData] = {
	possible_resources.Clay : load("res://Resources/Nodes/Resources/Clay.tres"),
	possible_resources.Logs : load("res://Resources/Nodes/Resources/Logs.tres"),
	possible_resources.Stones : load("res://Resources/Nodes/Resources/Stones.tres"),
	possible_resources.Planks : load("res://Resources/Nodes/Resources/Planks.tres"),
	possible_resources.StoneBlocks : load("res://Resources/Nodes/Resources/StoneBlocks.tres"),
	possible_resources.Bricks : load("res://Resources/Nodes/Resources/Bricks.tres"),
	possible_resources.ClayVessels : load("res://Resources/Nodes/Resources/ClayVessels.tres"),
	possible_resources.Token : load("res://Resources/Nodes/Resources/Token.tres"),
	possible_resources.ForestryToken : load("res://Resources/Nodes/Resources/ForestryToken.tres"),
	possible_resources.PotteryToken : load("res://Resources/Nodes/Resources/PotteryToken.tres"),
	possible_resources.MiningToken : load("res://Resources/Nodes/Resources/MiningToken.tres")
}

# Token ids
var token_ids : Dictionary[int, int] = {
	categories.All : possible_resources.Token,
	categories.Carpentry : possible_resources.ForestryToken,
	categories.Masonary : possible_resources.MiningToken,
	categories.Pottery : possible_resources.PotteryToken,
}

# All possible nodes ids
enum possible_nodes{Pine_tree = 0, Boulder = 1}

# Nodes resource data
var Nodes : Dictionary[int, ResourceNodeData] = {
	possible_nodes.Pine_tree : load("res://Resources/Nodes/Resources/PineTree.tres"),
	possible_nodes.Boulder : load("res://Resources/Nodes/Resources/Boulder.tres"),
}
