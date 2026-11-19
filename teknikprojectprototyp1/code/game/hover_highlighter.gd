extends Node2D

@onready var turnHandler = $"../../../.."
@onready var gridLayer = $".".get_parent()

var isMyTurn = false
var player: int
var player_grid_data: Dictionary

var last_hovered

func _ready():
	print("here")
	
	player = get_parent().get_parent().get_meta("Player")
	if player == 1:
		player_grid_data = MatchSettings.grid_data_p1
	elif player == 2:
		player_grid_data = MatchSettings.grid_data_p2
	turnHandler.turn_changed.connect(_turn_changed)

func _process(_delta: float) -> void:
	if not isMyTurn:
		return
	var mouse_pos = gridLayer.to_local(get_global_mouse_position())
	var tile_pos = gridLayer.local_to_map(mouse_pos)
	if last_hovered != tile_pos:
		last_hovered = tile_pos
		queue_redraw()

func _turn_changed(turn):
	var turnn = str(turn)
	if turnn == str(player - 1):
		isMyTurn = true
		queue_redraw()
	else:
		isMyTurn = false
		queue_redraw()

func _draw():
	if last_hovered == null:
		return
	if gridLayer.get_cell_source_id(last_hovered) == -1:
		return
	var tile_pos = gridLayer.map_to_local(last_hovered)
	var global_pos = gridLayer.to_global(tile_pos)
	var local_pos = to_local(global_pos)
	var tile_size = Vector2(gridLayer.tile_set.tile_size)
	var rect = Rect2(
		local_pos - tile_size / 2,
		tile_size
	)
	var tileType = player_grid_data.get(str(last_hovered), {}).get("tileType", "Unknown")
	if Configs.buildable_tiles.has(tileType):
		draw_rect(rect, Color.WHITE, false, 2.0)
	else:
		draw_rect(rect, Color.RED, false, 2.0)
