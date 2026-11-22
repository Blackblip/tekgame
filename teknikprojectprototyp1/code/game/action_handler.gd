extends Node2D
@onready var player = $GridContainer.get_meta("Player")
@onready var turnHandler = $".."
@onready var container

var icons = [
	
]
var schedule = {
	
}
var scheduled_recap = {
	
}

func _ready():
	turnHandler.turn_changed.connect(_turn_changed)

func _turn_changed(turn):
	if str(turn) != str(player):
		for i in icons:
			i.visible = false
	if str(turn) == "Prep":
		for i in icons:
			i.visible = false
	if str(turn) == str(player-1):
		for i in icons:
			i.visible = true

func perform_scheduled_actions():
	var completed = []
	print(schedule)
	for a in schedule:
		var aa = schedule[a]
		if aa.Type == "Build":
			if aa.Turns_left > 0:
				aa.Turns_left -= 1
				if aa.Turns_left != 0:
					continue
			
			if player == 1:
				MatchSettings.grid_data_p1[str(aa.tile_pos)].building = aa.Building
				MatchSettings.grid_data_p1[str(aa.tile_pos)].scheduled = false
				completed.append(a)
			elif player == 2:
				MatchSettings.grid_data_p2[str(aa.tile_pos)].building = aa.Building
				MatchSettings.grid_data_p2[str(aa.tile_pos)].scheduled = false
				completed.append(a)
			for i in icons:
				if i.name == str(aa.tile_pos):
					i.queue_free()
					icons.erase(i)
	for i in completed:
		schedule.erase(i)

func cancel_action(tile_pos):
	var key = str(tile_pos)

	if not schedule.has(key):
		return

	var action_data = schedule[key]
	var action_cost = 0

	# Determine action cost
	if action_data.Type == "Build":
		var building_data = Configs.buildings[action_data.Building]
		action_cost = building_data.ActionCost

	elif action_data.Type == "Offensive":
		var offensive_data = Configs.offensive_actions[action_data.Action]
		action_cost = offensive_data.ActionCost

	else:
		return

	# Refund action points
	if player == 1:
		MatchSettings.actionsLeftP1 += action_cost
		$"../../CenterContainer/UI/PActions".text = str(MatchSettings.actionsLeftP1)

	elif player == 2:
		MatchSettings.actionsLeftP2 += action_cost
		$"../../CenterContainer/UI/PActions".text = str(MatchSettings.actionsLeftP2)
	if action_data.Type == "Build":
		if player == 1:
			MatchSettings.grid_data_p1[key].scheduled = false
		elif player == 2:
			MatchSettings.grid_data_p2[key].scheduled = false
	var icon_instance = action_data.get("icon_instance")
	if is_instance_valid(icon_instance):
		icon_instance.queue_free()
		icons.erase(icon_instance)
	schedule.erase(key)


func schedule_offensive(action, tile_pos):
	print("here")
	var offensive_data = Configs.offensive_actions[action]
	
	var foundBuilding
	var amountOfBuildings = 0
	var amountAlreadyScheduled = 0
	for i in schedule:
		var data = schedule[i]
		if data.Type == "Offensive":
			if data.Action == offensive_data.Name:
				amountAlreadyScheduled += 1
	for i in $"./GridContainer/BUILDINGS".get_children():
		if i.get_meta("Building") == offensive_data.Needed_building:
			foundBuilding = true
			amountOfBuildings += 1
	print(amountOfBuildings, " ", amountAlreadyScheduled)
	if foundBuilding != true:
		return
	if amountAlreadyScheduled >= amountOfBuildings:
		return
	if player == 1:
		if offensive_data.ActionCost > MatchSettings.actionsLeftP1:
			$"../../Interactions".offensive = null
			return
		else:
			MatchSettings.actionsLeftP1 -= offensive_data.ActionCost
			$"../../CenterContainer/UI/PActions".text = str(MatchSettings.actionsLeftP1)
	elif player == 2:
		if offensive_data.ActionCost > MatchSettings.actionsLeftP2:
			$"../../Interactions".offensive = null
			return
		else:
			MatchSettings.actionsLeftP2 -= offensive_data.ActionCost
			$"../../CenterContainer/UI/PActions".text = str(MatchSettings.actionsLeftP2)

	var own_grid: TileMapLayer = $"./GridContainer/grid"
	var target_grid: TileMapLayer

	if player == 1:
		target_grid = $"../P2G/GridContainer/grid"
	else:
		target_grid = $"../P1G/GridContainer/grid"

	var missile_scene = load("res://Assets/Icons/missle.tscn")
	var missile_instance = missile_scene.instantiate()

	own_grid.add_child(missile_instance)

	var global_pos = target_grid.to_global(
		target_grid.map_to_local(tile_pos)
	)
	missile_instance.position = own_grid.to_local(global_pos)

	missile_instance.name = str(tile_pos)
	icons.append(missile_instance)

	schedule[str(tile_pos)] = {
		"Type": "Offensive",
		"Action": offensive_data.Name,
		"tile_pos": tile_pos,
		"icon_instance": missile_instance,
		"Turns_left": offensive_data.Travel_time
	}

func schedule_build(building, tile_pos):
	var build_data = Configs.buildings[building]
	if player == 1:
		if !Configs.buildable_tiles.has(MatchSettings.grid_data_p1[str(tile_pos)].tileType):
			return
		if MatchSettings.grid_data_p1[str(tile_pos)].building != "":
			$"../../Interactions".building = null
			$GridContainer/grid/HoverHighlight.build_mode = false
			return
		if MatchSettings.grid_data_p1[str(tile_pos)].scheduled == true:
			return
		if build_data.ActionCost > MatchSettings.actionsLeftP1:
			$"../../Interactions".building = null
			$GridContainer/grid/HoverHighlight.build_mode = false
			return
		else:
			MatchSettings.actionsLeftP1 -= build_data.ActionCost
			$"../../CenterContainer/UI/PActions".text = str(MatchSettings.actionsLeftP1)
			if MatchSettings.actionsLeftP1 == 0:
				$"../../Interactions".building = null
				$GridContainer/grid/HoverHighlight.build_mode = false
				$GridContainer/grid/HoverHighlight.queue_redraw()
	elif player == 2:
		if !Configs.buildable_tiles.has(MatchSettings.grid_data_p2[str(tile_pos)].tileType):
			return
		if MatchSettings.grid_data_p2[str(tile_pos)].building != "":
			return
		if MatchSettings.grid_data_p2[str(tile_pos)].scheduled == true:
			return
		if build_data.ActionCost > MatchSettings.actionsLeftP2:
			$"../../Interactions".building = null
			$GridContainer/grid/HoverHighlight.build_mode = false
			return
		else:
			MatchSettings.actionsLeftP2 -= build_data.ActionCost
			$"../../CenterContainer/UI/PActions".text = str(MatchSettings.actionsLeftP2)
			if MatchSettings.actionsLeftP2 == 0:
				$"../../Interactions".building = null
				$GridContainer/grid/HoverHighlight.build_mode = false
				$GridContainer/grid/HoverHighlight.queue_redraw()
	
	var hammer_scene = load("res://Assets/Icons/hammer.tscn")
	var hammer_instance = hammer_scene.instantiate()
	$"./GridContainer/grid".add_child(hammer_instance)
	var global_pos = $"./GridContainer/grid".to_global($"./GridContainer/grid".map_to_local(tile_pos))
	hammer_instance.global_position = global_pos
	hammer_instance.name = str(tile_pos)
	icons.append(hammer_instance)
	
	if player == 1:
		MatchSettings.grid_data_p1[str(tile_pos)].scheduled = true
	elif player == 2:
		MatchSettings.grid_data_p2[str(tile_pos)].scheduled = true
	
	schedule[str(tile_pos)] = {
		"Type": "Build",
		"Building": build_data.Name,
		"tile_pos": tile_pos,
		"icon_instance": hammer_instance,
		"Turns_left": build_data.BuildDuration
	}
