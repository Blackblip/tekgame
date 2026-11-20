extends Node
@onready var container = $Container
@onready var scroll = $"."
@onready var tempButton = $Container/Template

var selected_tile

func _ready():
	tempButton.visible = false

func show_actions_for_tile(tile_pos, player):
	var tile_data
	if player == 1:
		tile_data = MatchSettings.grid_data_p1[str(tile_pos)]
		if tile_data == null:
			return
		update_scroll(tile_data)
	elif player == 2:
		tile_data = MatchSettings.grid_data_p2[str(tile_pos)]
		if tile_data == null:
			return
		update_scroll(tile_data)

func update_scroll(tile_data):
	if !tile_data:
		selected_tile = null
		for i in container.get_children():
			if i.name != "Template":
				i.queue_free()
				if $"../TurnHandler/P2G/GridContainer".find_child("grid"):
					$"../TurnHandler/P2G/GridContainer/grid/SelectedHighlight".queue_redraw()
				if $"../TurnHandler/P1G/GridContainer".find_child("grid"):
					$"../TurnHandler/P1G/GridContainer/grid/SelectedHighlight".queue_redraw()
		return
	selected_tile = tile_data.tile_pos
	if $"../TurnHandler".current_turn == 0:
		$"../TurnHandler/P1G/GridContainer/grid/SelectedHighlight".queue_redraw()
	elif $"../TurnHandler".current_turn == 1:
		$"../TurnHandler/P2G/GridContainer/grid/SelectedHighlight".queue_redraw()
	
	for i in container.get_children():
		if i.name != "Template":
			i.free()
	if Configs.buildable_tiles.has(tile_data.tileType):
		for buildings in Configs.buildings:
			if tile_data.building != "":
				print("is built alrad")
				return
			if tile_data.scheduled == true:
				print("scheduled alrady")
				return
			
			var builds = Configs.buildings[buildings]
			var newButton = tempButton.duplicate()
			newButton.text = builds.Name
			newButton.visible = true
			$Container.add_child(newButton)
			newButton.pressed.connect(_build.bind(tile_data, builds))

func _build(tile_data, build_data):
	if $"../TurnHandler".current_turn == 0:
		$"../TurnHandler/P1G/GridContainer/grid/SelectedHighlight".queue_redraw()
		$"../TurnHandler/P1G".schedule_build(build_data, tile_data.tile_pos)
	elif $"../TurnHandler".current_turn == 1:
		$"../TurnHandler/P2G/GridContainer/grid/SelectedHighlight".queue_redraw()
		$"../TurnHandler/P2G".schedule_build(build_data, tile_data.tile_pos)
	update_scroll(null)
	
