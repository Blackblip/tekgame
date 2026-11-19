extends Node

var tile_types = {
	"Cloud": [4, Vector2i(0, 0)],
	"Grass": [0, Vector2i(0, 0)],
	"Mountain": [2, Vector2i(0, 0)],
	"Test": [3, Vector2i(0,0)],
	"GreenGrass": [1, Vector2i(0,0)]
}
var buildable_tiles = ["Grass", "Test", "GreenGrass"]
var buildings = {
	"Town": {
		"Name": "Town",
		"Path": "res://Assets/buildings/Town.tscn",
		"IconPath": "res://Assets/sprites/Big_City_Building_1.png",
		"ActionBonus": 1,
	},
	"Town2": {
		"Name": "Town2",
		"Path": "res://Assets/buildings/Town.tscn",
		"IconPath": "res://Assets/sprites/Big_City_Building_1.png",
		"ActionBonus": 1,
	},
}
