extends Node
@onready var container = $Container
@onready var scroll = $"."

func show_actions_for_tile(tile_pos, player):
	var tile_data
	if player == 1:
		tile_data = MatchSettings.grid_data_p1[tile_pos]
		if tile_data == null:
			print("tile doesnt exist")
			return
		update_scroll(tile_data)
	elif player == 2:
		tile_data = MatchSettings.grid_data_p1[tile_pos]
		if tile_data == null:
			print("tile doesnt exist")
			return
		update_scroll(tile_data)

func update_scroll(tile_data):
	if !tile_data:
		return
	if Configs.buildable_tiles.has(tile_data.tileType):
		for buildings in Configs.buildings:
			var builds = Configs.buildings[buildings]
			print(builds.Name)
