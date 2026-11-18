extends Node2D
@onready var turnHandler = $".."
@onready var gridLayer = $GridContainer/grid
@onready var gridLayerP1 = $"../P1G/GridContainer/grid"

signal grid_update(grid, updateInfo)
var isMyTurn = false

func _ready():
	print(MatchSettings.grid_data_p2)
	
	z_index = 10
	turnHandler.turn_changed.connect(_turn_changed)

var last_hovered
func _process(_delta: float) -> void:
	if isMyTurn == true:
		var mouse_pos = get_global_mouse_position()
		var tile_pos: Vector2i = gridLayer.local_to_map(gridLayer.to_local(mouse_pos))
		
		if not last_hovered == tile_pos:
			last_hovered = tile_pos
			queue_redraw()

func _turn_changed(turn):
	queue_redraw()
	var turnn = str(turn)
	if turnn == "1":
		isMyTurn = true
	if turnn == "Prep":
		isMyTurn = false
	if turnn == "0":
		isMyTurn = false

func _draw():
	if last_hovered == null:
		return
	if gridLayer.get_cell_source_id(last_hovered) == -1:
		return
	var tile_pos = to_global(last_hovered)
	var tile_size = Vector2(gridLayer.tile_set.tile_size)
	var rect = Rect2(
		tile_pos - tile_size / 2,
		tile_size
	)
	
	var key = Vector2i(tile_pos.x, tile_pos.y)
	var tile_type = MatchSettings.grid_data_p2[str(key)]["tileType"]
	if Configs.buildable_tiles.has(tile_type):
		draw_rect(rect, Color.WHITE, false, 2.0)
	else:
		draw_rect(rect, Color.RED, false, 2.0)
