extends Node2D
@onready var player = $GridContainer.get_meta("Player")
@onready var turnHandler = $".."
@onready var container

var icons = [
	
]
var schedule = {
	
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
		perform_scheduled_actions()
	if str(turn) == str(player-1):
		for i in icons:
			i.visible = true

func perform_scheduled_actions():
	var completed = []
	print(schedule)
	for a in schedule:
		var aa = schedule[a]
		if aa.Type == "Build":
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
func schedule_build(building, tile_pos):
	if player == 1:
		if building.ActionCost > MatchSettings.actionsLeftP1:
			return
		else:
			MatchSettings.actionsLeftP1 -= building.ActionCost
			$"../../CenterContainer/UI/PActions".text = str(MatchSettings.actionsLeftP1)
	elif player == 2:
		if building.ActionCost > MatchSettings.actionsLeftP2:
			return
		else:
			MatchSettings.actionsLeftP2 -= building.ActionCost
			$"../../CenterContainer/UI/PActions".text = str(MatchSettings.actionsLeftP2)
	
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
		"Building": building.Name,
		"tile_pos": tile_pos,
		"icon_instance": hammer_instance,
	}
