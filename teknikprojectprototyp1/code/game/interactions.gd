extends Node
@onready var container = $Container
@onready var scroll = $"."
@onready var tempButton = $Template
@onready var tempInfoUI = $"../CenterContainer/UI/Information/VContainer/Template"

var selected_tile
var selectEnable = true
var building

func _ready():
	$Main/Expansive.pressed.connect(_building_category_show.bind())
	$Main/Offensive.pressed.connect(_offensive_category_show.bind())
	tempButton.visible = false
	showorhide(false)
	for i in $".".get_children():
		for o in i.get_children():
			if o.name == "Return":
				o.pressed.connect(_return_to_main.bind())
			if o.name == "Cancel":
				o.pressed.connect(cancel.bind())
func cancel():
	$"../TurnHandler/P1G/GridContainer/grid/HoverHighlight".build_mode = false
	$"../TurnHandler/P2G/GridContainer/grid/HoverHighlight".build_mode = false
	var turn = $"../TurnHandler".current_turn
	if building == "Cancel":
		print("not here")
		if turn == 0:
			$"../TurnHandler/P1G/GridContainer/grid/HoverHighlight".cancel_mode = false
		elif turn == 1:
			$"../TurnHandler/P2G/GridContainer/grid/HoverHighlight".cancel_mode = false
		building = null
	elif building != "Cancel":
		print("here")
		if turn == 0:
			$"../TurnHandler/P1G/GridContainer/grid/HoverHighlight".cancel_mode = true
		elif turn == 1:
			$"../TurnHandler/P2G/GridContainer/grid/HoverHighlight".cancel_mode = true
		building = "Cancel"

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

func cleanse_info_ui():
	for i in $"../CenterContainer/UI/Information/VContainer".get_children():
		if i.name != "Template":
			i.queue_free()
func dupe_info_ui(text):
	var newUI = tempInfoUI.duplicate()
	$"../CenterContainer/UI/Information/VContainer".add_child(newUI)
	newUI.visible = true
	newUI.name = str(text)
	newUI.text = str(text)

func update_scroll(tile_data):
	cleanse_info_ui()
	if selectEnable == false:
		return
	if !tile_data:
		selected_tile = null
		cleanse_info_ui()
		return
	selected_tile = tile_data.tile_pos
	dupe_info_ui(tile_data.tile_id)
	dupe_info_ui(tile_data.tileType)
	if tile_data.building != "":
		dupe_info_ui(tile_data.building)
	if tile_data.scheduled == true:
		if $"../TurnHandler".current_turn == 0:
			var Building = $"../TurnHandler/P1G".schedule[str(tile_data.tile_pos)]
			dupe_info_ui(Building.Turns_left)
		elif $"../TurnHandler".current_turn == 1:
			var Building = $"../TurnHandler/P2G".schedule[str(tile_data.tile_pos)]
			dupe_info_ui(Building.Turns_left)
	if $"../TurnHandler".current_turn == 0:
		$"../TurnHandler/P1G/GridContainer/grid/SelectedHighlight".queue_redraw()
	elif $"../TurnHandler".current_turn == 1:
		$"../TurnHandler/P2G/GridContainer/grid/SelectedHighlight".queue_redraw()
func showorhide(boolean):
	building = null
	if boolean == true:
		$".".visible = true
	else:
		$".".visible = false
	if !$"../TurnHandler/P1G/GridContainer/grid/HoverHighlight":
		return
	if !$"../TurnHandler/P2G/GridContainer/grid/HoverHighlight":
		return
	if $"../TurnHandler".current_turn == 0:
			$"../TurnHandler/P1G/GridContainer/grid/HoverHighlight".build_mode = false
			$"../TurnHandler/P1G/GridContainer/grid/HoverHighlight".cancel_mode = false
	elif $"../TurnHandler".current_turn == 1:
		$"../TurnHandler/P2G/GridContainer/grid/HoverHighlight".build_mode = false
		$"../TurnHandler/P1G/GridContainer/grid/HoverHighlight".cancel_mode = false
func _return_to_main():
	cleanse_info_ui()
	selected_tile = null
	$"../TurnHandler/P2G/GridContainer/grid/SelectedHighlight".queue_redraw()
	$"../TurnHandler/P1G/GridContainer/grid/SelectedHighlight".queue_redraw()
	
	$Expansive.visible = false
	$Defensive.visible = false
	$Offensive.visible = false
	$Main.visible = true
	
	building = null
	if !$"../TurnHandler/P1G/GridContainer/grid/HoverHighlight":
		return
	if !$"../TurnHandler/P2G/GridContainer/grid/HoverHighlight":
		return
	$"../TurnHandler/P2G/GridContainer/grid/HoverHighlight".build_mode = false
	$"../TurnHandler/P1G/GridContainer/grid/HoverHighlight".build_mode = false
	$"../TurnHandler/P2G/GridContainer/grid/HoverHighlight".cancel_mode = false
	$"../TurnHandler/P1G/GridContainer/grid/HoverHighlight".cancel_mode = false
func _building_category_show():
	cleanse_info_ui()
	selected_tile = null
	$"../TurnHandler/P2G/GridContainer/grid/SelectedHighlight".queue_redraw()
	$"../TurnHandler/P1G/GridContainer/grid/SelectedHighlight".queue_redraw()
	
	$Expansive.visible = true
	$Defensive.visible = false
	$Offensive.visible = false
	$Main.visible = false
	for i in $Expansive.get_children():
		if i.name != "Cancel" and i.name != "Return":
			i.queue_free()
	for i in Configs.buildings:
		var building_data = Configs.buildings[i]
		if $Expansive.find_child(building_data.Name):
			continue
		var newButton: TextureButton = tempButton.duplicate()
		newButton.texture_normal = load(building_data.IconPath)
		$Expansive.add_child(newButton)
		newButton.name = building_data.Name
		newButton.visible = true
		newButton.pressed.connect(_build.bind(building_data))
func _offensive_category_show():
	cleanse_info_ui()
	selected_tile = null
	$"../TurnHandler/P2G/GridContainer/grid/SelectedHighlight".queue_redraw()
	$"../TurnHandler/P1G/GridContainer/grid/SelectedHighlight".queue_redraw()
	
	$Expansive.visible = false
	$Defensive.visible = false
	$Offensive.visible = true
	$Main.visible = false
	for i in $Offensive.get_children():
		if i.name != "Cancel" and i.name != "Return":
			i.queue_free()
	for i in Configs.offensive_actions:
		var offensive_data = Configs.offensive_actions[i]
		var newButton: TextureButton = tempButton.duplicate()
		newButton.texture_normal = load(offensive_data.IconPath)
		$Offensive.add_child(newButton)
		newButton.name = offensive_data.Name
		newButton.visible = true
		newButton.pressed.connect(_offensive.bind(offensive_data))

func _offensive(offensive_data):
	print(offensive_data)
func _build(build_data):
	cleanse_info_ui()
	print(build_data.Name)
	selected_tile = null
	if $"../TurnHandler".current_turn == 0:
		$"../TurnHandler/P1G/GridContainer/grid/SelectedHighlight".queue_redraw()
	elif $"../TurnHandler".current_turn == 1:
		$"../TurnHandler/P2G/GridContainer/grid/SelectedHighlight".queue_redraw()
	if building == build_data.Name:
		building = null
		if $"../TurnHandler".current_turn == 0:
			$"../TurnHandler/P1G/GridContainer/grid/HoverHighlight".build_mode = false
			$"../TurnHandler/P1G/GridContainer/grid/HoverHighlight".cancel_mode = false
		elif $"../TurnHandler".current_turn == 1:
			$"../TurnHandler/P2G/GridContainer/grid/HoverHighlight".build_mode = false
			$"../TurnHandler/P1G/GridContainer/grid/HoverHighlight".cancel_mode = false
		return
	building = build_data.Name
	dupe_info_ui(build_data.Name)
	if $"../TurnHandler".current_turn == 0:
		$"../TurnHandler/P1G/GridContainer/grid/HoverHighlight".build_mode = true
		$"../TurnHandler/P1G/GridContainer/grid/HoverHighlight".cancel_mode = false
	elif $"../TurnHandler".current_turn == 1:
		$"../TurnHandler/P2G/GridContainer/grid/HoverHighlight".build_mode = true
		$"../TurnHandler/P1G/GridContainer/grid/HoverHighlight".cancel_mode = false
