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
	-1 : "",
	0 : "Clayland",
	1 : "Forest",
	2 : "Mountains",
}

# Biomes [name : array of region nodes]
var biome_resource_nodes : Dictionary[String, Array] = {
	"Clayland" : [],
	"Forest" : ["Pine_tree"],
	"Mountains" : ["Boulder"],
}
