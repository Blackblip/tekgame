
extends TileMapLayer

@onready var player = get_parent().get_meta("Player")
@onready var gridLayer = self
@onready var turnHandler = $"../../.."
@onready var interactions = $"../../../../Interactions"

var gridLayer2: TileMapLayer

var isMyTurn = false

var tile_pos = Vector2i(-100, -100)
var target_grid: TileMapLayer
var target_player: int

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

	queue_redraw()



func _input(event):
	if not isMyTurn:
		return

	if not event is InputEventMouseButton:
		return

	if event.button_index != MOUSE_BUTTON_LEFT or not event.pressed:
		return

	var mouse_pos = get_global_mouse_position()

	var own_pos = gridLayer.local_to_map(
		gridLayer.to_local(mouse_pos)
	)

	var opponent_pos = gridLayer2.local_to_map(
		gridLayer2.to_local(mouse_pos)
	)

	var own_has_tile = gridLayer.get_cell_source_id(own_pos) != -1
	var opponent_has_tile = gridLayer2.get_cell_source_id(opponent_pos) != -1

	# Offensive mode
	if interactions.offensive != null:
		if not opponent_has_tile:
			return

		target_grid = gridLayer2
		target_player = 3 - player
		tile_pos = opponent_pos

		get_parent().get_parent().schedule_offensive(
			interactions.offensive,
			tile_pos
		)

		return

	# Cancel mode
	if interactions.building == "Cancel":
		if opponent_has_tile:
			get_parent().get_parent().cancel_action(opponent_pos)
			return

		if own_has_tile:
			get_parent().get_parent().cancel_action(own_pos)

		return

	# Normal interaction
	if not own_has_tile:
		return

	target_grid = gridLayer
	target_player = player
	tile_pos = own_pos

	if interactions.building == null:
		interactions.show_actions_for_tile(
			tile_pos,
			target_player,
			target_grid
		)

	else:
		get_parent().get_parent().schedule_build(
			interactions.building,
			tile_pos
		)
