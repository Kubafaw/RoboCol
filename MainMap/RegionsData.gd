extends Node

"""
Pine_tree
Berry_bush
Boulder
"""

# Regions name and id
enum possible_regions{None = -1, Clayland = 0, Forest = 1, Mountains = 2}

# Regions [number : name]
var Regions : Dictionary[int, String] = {
	possible_regions.None : "",
	possible_regions.Clayland : "Clayland",
	possible_regions.Forest : "Forest",
	possible_regions.Mountains : "Mountains",
}

# Biomes [name : array of region nodes]
var biome_resource_nodes : Dictionary[String, Array] = {
	"Clayland" : [],
	"Forest" : [ResD.possible_nodes.Pine_tree],
	"Mountains" : [ResD.possible_nodes.Boulder],
}
