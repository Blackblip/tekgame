extends Node2D
@onready var turnHandler = $".."
@onready var gridLayer = $GridContainer/grid
@onready var gridLayerP1 = $"../P1G/GridContainer/grid"

signal grid_update(grid, updateInfo)
var isMyTurn = false

func _ready():
	z_index = 10
	turnHandler.turn_changed.connect(_turn_changed)
	for cell in gridLayerP1.get_used_cells():
		MatchSettings.grid_data_p1_p2_perspective[str(cell)] = {
			"hidden" : true,
			"building" : "Unknown",
			"connectedBuildings" : {},
			"tileType" : "Unknown",
		}

var last_hovered
func _process(_delta: float) -> void:
	if isMyTurn == true:
		var mouse_pos = gridLayer.to_local(get_global_mouse_position())
		var tile_pos = gridLayer.local_to_map(mouse_pos)
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
	var tile_pos = gridLayer.map_to_local(last_hovered)
	var global_pos = gridLayer.to_global(tile_pos)
	var local_pos = to_local(global_pos)
	var tile_size = Vector2(gridLayer.tile_set.tile_size)
	var rect = Rect2(
	local_pos - tile_size / 2,
	tile_size
	)
	var tileType = MatchSettings.grid_data_p2[str(last_hovered)]["tileType"]
	if Configs.buildable_tiles.has(tileType):
		draw_rect(rect, Color.WHITE, false, 2.0)
	else:
		draw_rect(rect, Color.RED, false, 2.0)
