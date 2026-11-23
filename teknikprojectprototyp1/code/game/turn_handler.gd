extends Node
class_name TurnHandler

@onready var UI = $"../CenterContainer/UI"
@onready var endButton = $"../CenterContainer/UI/EndTurn"
@onready var startButton = $"../CenterContainer/UI/StartTurn"
@onready var turnsLeftUI = $"../CenterContainer/UI/TurnsLeft"
@onready var actionsUI = $"../CenterContainer/UI/PActions"

@onready var p1Node = $P1G
@onready var player1Name = $P1G/pName
@onready var p2Node = $P2G
@onready var player2Name = $P2G/pName

@onready var p1Grid
@onready var p2Grid

@onready var templateID = $TileIDS/TemplateID
@onready var tileIDS = $TileIDS

enum Turn { PLAYER1, PLAYER2 }
var current_turn: Turn
var isPrep = true

var turns_left = 0

signal turn_changed(new_turn)
var gameGoing = false

func prepare_grid_data():
	p1Grid = $P1G/GridContainer/grid
	p2Grid = $P2G/GridContainer/grid
	
	for cell in p1Grid.get_used_cells():
		var tile_data = p1Grid.get_cell_tile_data(cell)
		var tileType
		tileType = tile_data.get_custom_data("tileType")
		
		MatchSettings.grid_data_p1[str(cell)] = {
			"building" : "",
			"connectedBuildings" : {}, 
			"tileType" : tileType,
			"tile_pos" : cell,
			"tile_id" : str(cell.x) + "_" + str(cell.y),
			"scheduled" : false,
			"broken" : false,
			"protected" : {
				"isProtected": false,
				"protectedFor": 0,
			},
			"action_scheduled_on": "",
		}
		MatchSettings.grid_data_p1_p2_perspective[str(cell)] = {
			"hidden" : true,
			"building" : false,
			"tile_pos" : cell,
			"marked": "",
		}
		
		var tileID = templateID.duplicate()
		tileIDS.add_child(tileID)
		var global_pos = p1Grid.to_global(p1Grid.map_to_local(cell))
		var local_pos = tileIDS.get_global_transform_with_canvas().affine_inverse() * global_pos
		tileID.position = local_pos - tileID.size / 2.0
		tileID.visible = true
		tileID.text = str(MatchSettings.grid_data_p1[str(cell)].tile_id)
	for cell in p2Grid.get_used_cells():
		var tile_data = p2Grid.get_cell_tile_data(cell)
		var tileType
		tileType = tile_data.get_custom_data("tileType")
		
		MatchSettings.grid_data_p2[str(cell)] = {
			"building" : "",
			"connectedBuildings" : {}, 
			"tileType" : tileType,
			"tile_pos" : cell,
			"tile_id" : str(cell.x) + "_" + str(cell.y),
			"scheduled" : false,
			"broken": false,
			"protected" : {
				"isProtected": false,
				"protectedFor": 0,
			},
			"action_scheduled_on": "",
		}
		MatchSettings.grid_data_p2_p1_perspective[str(cell)] = {
			"hidden" : true,
			"building" : false,
			"tile_pos" : cell,
			"marked": "",
		}
		var tileID = templateID.duplicate()
		tileIDS.add_child(tileID)
		var global_pos = p2Grid.to_global(p1Grid.map_to_local(cell))
		var local_pos = tileIDS.get_global_transform_with_canvas().affine_inverse() * global_pos
		tileID.position = local_pos - tileID.size / 2.0
		tileID.visible = true
		tileID.text = str(MatchSettings.grid_data_p2[str(cell)].tile_id)

func update_grid_visuals():
	if current_turn == 0:
		for cell in p1Grid.get_used_cells():
			var _tile_data = p1Grid.get_cell_tile_data(cell)
			var tile_type = MatchSettings.grid_data_p1[str(cell)].tileType
			if Configs.tile_types.has(tile_type):
				var tile = Configs.tile_types[tile_type]
				p1Grid.set_cell(cell, tile[0], tile[1])
		for cell in p2Grid.get_used_cells():
			if MatchSettings.grid_data_p2_p1_perspective[str(cell)]["building"] == true:
				var cell_data = MatchSettings.grid_data_p2[str(cell)]
				$P2G/GridContainer/BUILDINGS.spawn_building(cell_data)
			if MatchSettings.grid_data_p2_p1_perspective[str(cell)]["marked"] == "correct":
				var tile = Configs.tile_types["HitMark"]
				p2Grid.set_cell(cell, tile[0], tile[1])
			if MatchSettings.grid_data_p2_p1_perspective[str(cell)]["marked"] == "incorrect":
				var tile = Configs.tile_types["FailMark"]
				p2Grid.set_cell(cell, tile[0], tile[1])
			if MatchSettings.grid_data_p2_p1_perspective[str(cell)]["hidden"] == true and MatchSettings.grid_data_p2_p1_perspective[str(cell)]["marked"] == "":
				p2Grid.set_cell(cell, 4, Vector2i(0, 0))
			elif MatchSettings.grid_data_p2_p1_perspective[str(cell)]["hidden"] == false:
				var tile_type = MatchSettings.grid_data_p2[str(cell)].tileType
				if Configs.tile_types.has(tile_type):
					var tile = Configs.tile_types[tile_type]
					p2Grid.set_cell(cell, tile[0], tile[1])
	elif current_turn == 1:
		for cell in p2Grid.get_used_cells():
			var _tile_data = p2Grid.get_cell_tile_data(cell)
			var tile_type = MatchSettings.grid_data_p2[str(cell)].tileType
			if Configs.tile_types.has(tile_type):
				var tile = Configs.tile_types[tile_type]
				p2Grid.set_cell(cell, tile[0], tile[1])
		for cell in p1Grid.get_used_cells():
			if MatchSettings.grid_data_p2_p1_perspective[str(cell)]["building"] == true:
				var cell_data = MatchSettings.grid_data_p1[str(cell)]
				$P1G/GridContainer/BUILDINGS.spawn_building(cell_data)
			if MatchSettings.grid_data_p1_p2_perspective[str(cell)]["marked"] == "correct":
				var tile = Configs.tile_types["HitMark"]
				p1Grid.set_cell(cell, tile[0], tile[1])
			if MatchSettings.grid_data_p1_p2_perspective[str(cell)]["marked"] == "incorrect":
				var tile = Configs.tile_types["FailMark"]
				p1Grid.set_cell(cell, tile[0], tile[1])
			if MatchSettings.grid_data_p1_p2_perspective[str(cell)]["hidden"] == true and MatchSettings.grid_data_p1_p2_perspective[str(cell)]["marked"] == "":
				p1Grid.set_cell(cell, 4, Vector2i(0, 0))
			elif MatchSettings.grid_data_p1_p2_perspective[str(cell)]["hidden"] == false:
				var tile_type = MatchSettings.grid_data_p1[str(cell)].tileType
				if Configs.tile_types.has(tile_type):
					var tile = Configs.tile_types[tile_type]
					p1Grid.set_cell(cell, tile[0], tile[1])

func _ready():
	tileIDS.visible = false
	p1Node.visible = false
	p2Node.visible = false
	UI.visible = false
	
	MatchSettings.actionsPerTurnP1 = MatchSettings.starting_actions
	MatchSettings.actionsPerTurnP2 = MatchSettings.starting_actions
	
	player1Name.text = str(MatchSettings.p1_name)
	player2Name.text = str(MatchSettings.p2_name)
	
	turns_left = MatchSettings.total_turns
	turnsLeftUI.text = str(turns_left)
	
	endButton.visible = false
	startButton.pressed.connect(_start_turn_pressed)
	endButton.pressed.connect(_end_turn_pressed)

func _start_game():
	prepare_grid_data()
	p1Node.visible = true
	p2Node.visible = true
	p1Grid.visible = true
	p2Grid.visible = true
	UI.visible = true
	
	gameGoing = true
	prepare_turn()

func _start_turn_pressed():
	start_turn()
func _end_turn_pressed():
	if turns_left >= 1:
		next_turn()
	if turns_left <= 0:
		print("game ended")

func prepare_turn():
	if gameGoing == false:
		return
	
	$"../Interactions".showorhide(false)
	isPrep = true
	turn_changed.emit("Prep")
	
	match current_turn:
		Turn.PLAYER1:
			for cell in p2Grid.get_used_cells():
				p2Grid.set_cell(cell, 4, Vector2i(0, 0))
			for cell in p1Grid.get_used_cells():
				p1Grid.set_cell(cell, 4, Vector2i(0, 0))
			
			#p1Node.visible = false
			#p2Node.visible = false
			
			actionsUI.text = "?"
			
			startButton.visible = true
			endButton.visible = false
		Turn.PLAYER2:
			for cell in p2Grid.get_used_cells():
				p2Grid.set_cell(cell, 4, Vector2i(0, 0))
			for cell in p1Grid.get_used_cells():
				p1Grid.set_cell(cell, 4, Vector2i(0, 0))
			
			#p1Node.visible = false
			#p2Node.visible = false
			
			actionsUI.text = "?"
			
			startButton.visible = true
			endButton.visible = false

var loop_count = 1
func next_turn():
	if gameGoing == false:
		return
	loop_count += 1
	if loop_count >= 3:
		$P1G.perform_scheduled_actions()
		$P2G.perform_scheduled_actions()
		turns_left = turns_left - 1
		MatchSettings.turns_left = turns_left
		loop_count = 1
	turnsLeftUI.text = str(turns_left)
	
	match current_turn:
		Turn.PLAYER1:
			current_turn = Turn.PLAYER2
			prepare_turn()
		Turn.PLAYER2:
			current_turn = Turn.PLAYER1
			prepare_turn()

func start_turn():
	if gameGoing == false:
		return
	isPrep = false
	turn_changed.emit(current_turn)
	$P1G.queue_redraw()
	$P2G.queue_redraw()
	$"../Interactions".update_scroll(null)
	$"../Interactions".showorhide(true)
	$"../Interactions"._return_to_main()
	
	match current_turn:
		Turn.PLAYER1:
			MatchSettings.actionsLeftP1 = MatchSettings.actionsPerTurnP1
			actionsUI.text = str(MatchSettings.actionsLeftP1)
			endButton.visible = true
			startButton.visible = false
			update_grid_visuals()
		Turn.PLAYER2:
			MatchSettings.actionsLeftP2 = MatchSettings.actionsPerTurnP2
			actionsUI.text = str(MatchSettings.actionsLeftP2)
			startButton.visible = false
			endButton.visible = true
			update_grid_visuals()
