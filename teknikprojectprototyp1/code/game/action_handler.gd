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
	if schedule.has(str(tile_pos)):
		var building_data = Configs.buildings[schedule[str(tile_pos)].Building]
		if player == 1:
			MatchSettings.actionsLeftP1 += building_data.ActionCost
			$"../../CenterContainer/UI/PActions".text = str(MatchSettings.actionsLeftP1)
		elif player == 2:
			MatchSettings.actionsLeftP2 += building_data.ActionCost
			$"../../CenterContainer/UI/PActions".text = str(MatchSettings.actionsLeftP2)
		schedule.erase(str(tile_pos))
		for i in icons:
			if i.name == str(tile_pos):
				i.queue_free()
				icons.erase(i)
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
