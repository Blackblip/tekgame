
extends Node

@onready var scroll = self
@onready var tempButton = $Template
@onready var tempInfoUI = $"../CenterContainer/UI/Information/VContainer/Template"

@onready var p1_hover = $"../TurnHandler/P1G/GridContainer/grid/HoverHighlight"
@onready var p2_hover = $"../TurnHandler/P2G/GridContainer/grid/HoverHighlight"

@onready var p1_selected = $"../TurnHandler/P1G/GridContainer/grid/SelectedHighlight"
@onready var p2_selected = $"../TurnHandler/P2G/GridContainer/grid/SelectedHighlight"

var selected_tile
var selected_grid: TileMapLayer

var selectEnable = true
var building
var offensive

func _ready():
	$Main/Expansive.pressed.connect(_building_category_show.bind())
	$Main/Offensive.pressed.connect(_offensive_category_show.bind())

	tempButton.visible = false
	showorhide(false)

	for i in get_children():
		print(i.name)
		for o in i.get_children():
			print(o.name)
			if o.name == "Return":
				o.pressed.connect(_return_to_main.bind())
			if o.name == "Cancel":
				o.pressed.connect(cancel.bind())

func clear_selection():
	selected_tile = null
	selected_grid = null
	
	if p1_selected == null:
		p1_selected = $"../TurnHandler/P1G/GridContainer/grid/SelectedHighlight"
		return
	if p2_selected == null:
		p2_selected = $"../TurnHandler/P2G/GridContainer/grid/SelectedHighlight"
		return
	
	p1_selected.queue_redraw()
	p2_selected.queue_redraw()


func show_actions_for_tile(tile_pos, player, grid):
	var tile_data

	if player == 1:
		tile_data = MatchSettings.grid_data_p1.get(str(tile_pos))
	elif player == 2:
		tile_data = MatchSettings.grid_data_p2.get(str(tile_pos))

	if tile_data == null:
		return

	selected_grid = grid
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
		clear_selection()
		return

	selected_tile = tile_data.tile_pos

	p1_selected.queue_redraw()
	p2_selected.queue_redraw()

	dupe_info_ui(tile_data.tile_id)
	dupe_info_ui(tile_data.tileType)

	if tile_data.building != "":
		dupe_info_ui(tile_data.building)
	if str(tile_data.action_scheduled_on) != "":
		dupe_info_ui(str("Targeting: ", tile_data.action_scheduled_on))

	if tile_data.scheduled == true:
		if $"../TurnHandler".current_turn == 0:
			var Building = $"../TurnHandler/P1G".schedule[str(tile_data.tile_pos)]
			dupe_info_ui(Building.Turns_left)

		elif $"../TurnHandler".current_turn == 1:
			var Building = $"../TurnHandler/P2G".schedule[str(tile_data.tile_pos)]
			dupe_info_ui(Building.Turns_left)

func set_hover_modes(build_mode_value, cancel_mode_value):
	if p1_hover == null:
		p1_hover = $"../TurnHandler/P1G/GridContainer/grid/HoverHighlight"
		return
	if p2_hover == null:
		p2_hover = $"../TurnHandler/P2G/GridContainer/grid/HoverHighlight"
		return
	
	p1_hover.build_mode = build_mode_value
	p2_hover.build_mode = build_mode_value

	p1_hover.cancel_mode = cancel_mode_value
	p2_hover.cancel_mode = cancel_mode_value

	p1_hover.queue_redraw()
	p2_hover.queue_redraw()

func cancel():
	clear_selection()
	cleanse_info_ui()
	dupe_info_ui("Cancel")
	if offensive != null:
		offensive = null
		building = "Cancel"
		set_hover_modes(false, true)
		return
	if building == "Cancel":
		cleanse_info_ui()
		building = null
		set_hover_modes(false, false)
	else:
		building = "Cancel"
		set_hover_modes(false, true)

func showorhide(boolean):
	building = null
	offensive = null
	$".".visible = boolean
	set_hover_modes(false, false)

func _return_to_main():
	cleanse_info_ui()
	clear_selection()
	$Expansive.visible = false
	$Defensive.visible = false
	$Offensive.visible = false
	$Main.visible = true
	building = null
	offensive = null
	set_hover_modes(false, false)

func _building_category_show():
	cleanse_info_ui()
	clear_selection()

	offensive = null
	building = null

	$Expansive.visible = true
	$Defensive.visible = false
	$Offensive.visible = false
	$Main.visible = false

	set_hover_modes(false, false)

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
	clear_selection()
	building = null
	offensive = null
	$Expansive.visible = false
	$Defensive.visible = false
	$Offensive.visible = true
	$Main.visible = false
	set_hover_modes(false, false)
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
	clear_selection()
	cleanse_info_ui()
	if offensive == offensive_data.Name:
		offensive = null
		set_hover_modes(false, false)
		return
	
	building = null
	offensive = offensive_data.Name
	set_hover_modes(false, false)
	dupe_info_ui(offensive_data.Name)
	var required_buildings = []
	if offensive_data.Needed_buildings != null:
		for i in offensive_data.Needed_buildings:
			required_buildings.append(i)
	dupe_info_ui(str("Required buildings: ", required_buildings))

func _build(build_data):
	cleanse_info_ui()
	clear_selection()

	print(build_data.Name)

	offensive = null

	if building == build_data.Name:
		building = null
		set_hover_modes(false, false)
		return

	building = build_data.Name

	dupe_info_ui(build_data.Name)
	dupe_info_ui(str("Cost: ", build_data.ActionCost))
	if build_data.ActionBonus > 0:
		dupe_info_ui(str("Actions given: ", build_data.ActionBonus))
	dupe_info_ui(str("Duration until done: ", build_data.BuildDuration))

	set_hover_modes(true, false)
