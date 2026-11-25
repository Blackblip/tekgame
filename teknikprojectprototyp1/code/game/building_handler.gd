extends Node

@onready var player = $"..".get_meta("Player")
@onready var turnHandler = $"../../.."

var actionsToGive

func spawn_building(tile_data):
	if $".".find_child(str(tile_data.tile_pos)):
		return
	if tile_data.building == "":
		return
	
	var tile_pos = tile_data.tile_pos
	var path = Configs.buildings[tile_data.building].Path
	var building_scene = load(path)
	var building_instance = building_scene.instantiate()
	if building_instance is AnimatedSprite2D:
		if str(tile_data.action_scheduled_on) != "":
			building_instance.play("prep")
		else:
			building_instance.play("default")
	$".".add_child(building_instance)
	var global_pos = $"../../GridContainer/grid".to_global($"../../GridContainer/grid".map_to_local(tile_pos))
	building_instance.global_position = global_pos
	building_instance.name = str(tile_data.tile_pos)
	building_instance.z_index = 100
	building_instance.set_meta("tile_pos", tile_data.tile_pos)
	building_instance.set_meta("Building", tile_data.building)
	actionsToGive = 0
	updateActions()

func updateActions():
	actionsToGive = 0
	if player == 1:
		for i in $".".get_children():
			actionsToGive += Configs.buildings[i.get_meta("Building")].ActionBonus
			MatchSettings.actionsPerTurnP1 = MatchSettings.starting_actions + actionsToGive
			MatchSettings.actionsLeftP1 = MatchSettings.actionsPerTurnP1
			$"../../../../CenterContainer/UI/PActions".text = str(MatchSettings.actionsLeftP1)
	elif player == 2:
		for i in $".".get_children():
			actionsToGive += Configs.buildings[i.get_meta("Building")].ActionBonus
			MatchSettings.actionsPerTurnP2 = MatchSettings.starting_actions + actionsToGive
			MatchSettings.actionsLeftP2 = MatchSettings.actionsPerTurnP2
			$"../../../../CenterContainer/UI/PActions".text = str(MatchSettings.actionsLeftP2)
	print(actionsToGive)

func _ready():
	turnHandler.turn_changed.connect(_turn_changed)
func _turn_changed(turn):
	for i in $".".get_children():
		i.queue_free()
	if str(turn) == str(player - 1):
		var grid = $"../grid"
		if player == 1:
			for i in $".".get_children():
				i.visible = true
			for cell in grid.get_used_cells():
				var tile_data = MatchSettings.grid_data_p1[str(cell)]
				if tile_data.building != "":
					if $".".find_child(str(tile_data.tile_pos)):
						return
					if Configs.buildings.has(tile_data.building):
						spawn_building(tile_data)
		elif player == 2:
			for i in $".".get_children():
				i.visible = true
			for cell in grid.get_used_cells():
				var tile_data = MatchSettings.grid_data_p2[str(cell)]
				if tile_data.building != "":
					if $".".find_child(str(tile_data.tile_pos)):
						return
					if Configs.buildings.has(tile_data.building):
						spawn_building(tile_data)
	elif str(turn) != str(player):
		if player == 1:
			for i in $".".get_children():
				i.queue_free()
		elif player == 2:
			for i in $".".get_children():
				i.queue_free()
