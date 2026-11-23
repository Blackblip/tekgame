extends Node

var tile_types = {
	"Cloud": [4, Vector2i(0, 0)],
	"Grass": [0, Vector2i(0, 0)],
	"Mountain": [2, Vector2i(0, 0)],
	"Test": [3, Vector2i(0,0)],
	"GreenGrass": [1, Vector2i(0,0)],
	"FailMark": [10, Vector2i(0,0)],
	"HitMark": [11, Vector2i(0,0)]
}
var buildable_tiles = ["Grass", "Test", "GreenGrass"]
var buildings = {
	"Town": {
		"Name": "Town",
		"Path": "res://Assets/buildings/Town.tscn",
		"IconPath": "res://Assets/sprites/Big_City_Building_1.png",
		"ActionBonus": 1,
		"ActionCost": 1,
		"BuildDuration": 1,
		"CostIncrease": 1,
	},
	"MissileSilo": {
		"Name": "MissileSilo",
		"Path": "res://Assets/buildings/MissileSilo.tscn",
		"IconPath": "res://Assets/sprites/missilesilo.png",
		"ActionBonus": 0,
		"ActionCost": 4,
		"BuildDuration": 1,
		"CostIncrease": 1,
	},
}
var offensive_actions = {
	"Missile": {
		"Type": "Bomb",
		"Name": "Missile",
		"IconPath": "res://Assets/sprites/missilesilo.png",
		"Path": "res://Assets/buildings/MissileSilo.tscn",
		"Needed_buildings": ["MissileSilo"],
		"Source_building": "MissileSilo",
		"ActionCost": 2,
		"Travel_time": 2,
		"Size": 1,
	},
}
