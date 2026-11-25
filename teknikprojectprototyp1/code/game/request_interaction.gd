extends TileMapLayer

@onready var player = get_parent().get_meta("Player")
@onready var gridLayer = self
@onready var turnHandler = $"../../.."
@onready var interactions = $"../../../../Interactions"
@onready var sound_handler

var gridLayer2: TileMapLayer

var isMyTurn = false

var tile_pos = Vector2i(-100, -100)
var target_grid: TileMapLayer
var target_player: int

var isDragging = false
var drag_building = null

func _ready():
	if player == 1:
		gridLayer2 = $"../../../P2G/GridContainer/grid"
	elif player == 2:
		gridLayer2 = $"../../../P1G/GridContainer/grid"
	turnHandler.turn_changed.connect(_turn_changed)

func _turn_changed(turn):
	if player == 1:
		gridLayer2 = $"../../../P2G/GridContainer/grid"
	elif player == 2:
		gridLayer2 = $"../../../P1G/GridContainer/grid"
	interactions.update_scroll(null)
	isMyTurn = str(turn) == str(player - 1)
	isDragging = false
	drag_building = null
	queue_redraw()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if player == 0:
				sound_handler = $"../../../../SoundsP1"
				sound_handler.play_sound("Click")
			if player == 1:
				sound_handler = $"../../../../SoundsP2"
				sound_handler.play_sound("Click")
	if not isMyTurn:
		return
	if event.is_action_pressed("Shift"):
		$"../../../TileIDS".visible = true
	if event.is_action_released("Shift"):
		$"../../../TileIDS".visible = false
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				isDragging = true
				place_at_mouse()
			else:
				isDragging = false
	if event is InputEventMouseMotion and isDragging:
		place_at_mouse()


func place_at_mouse():
	var mouse_pos = get_global_mouse_position()
	var own_pos = gridLayer.local_to_map(
		gridLayer.to_local(mouse_pos)
	)
	var opponent_pos = gridLayer2.local_to_map(
		gridLayer2.to_local(mouse_pos)
	)
	if interactions.offensive != null:
		if gridLayer2.get_cell_source_id(opponent_pos) == -1:
			return
		get_parent().get_parent().schedule_offensive(
			interactions.offensive,
			opponent_pos
		)
		return

	if interactions.building == "Cancel":
		if gridLayer2.get_cell_source_id(opponent_pos) != -1:
			get_parent().get_parent().cancel_action(opponent_pos)
		elif gridLayer.get_cell_source_id(own_pos) != -1:
			get_parent().get_parent().cancel_action(own_pos)
		return
	if interactions.building != null:
		if gridLayer.get_cell_source_id(own_pos) == -1:
			return
		get_parent().get_parent().schedule_build(
			interactions.building,
			own_pos
		)
		return
	if gridLayer.get_cell_source_id(own_pos) != -1:
		show_tile_actions(own_pos)

func show_tile_actions(pos):
	target_grid = gridLayer
	target_player = player
	tile_pos = pos

	interactions.show_actions_for_tile(
		tile_pos,
		target_player,
		target_grid
	)
