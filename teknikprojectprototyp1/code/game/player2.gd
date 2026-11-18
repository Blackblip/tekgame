extends Node2D
@onready var turnHandler = $".."
@onready var gridLayer = $GridContainer/grid
@onready var gridLayerP1 = $"../P1G/GridContainer/grid"
@onready var cloudLayerP1 = $"../P1G/cloudGrid"

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
	for cell in gridLayer.get_used_cells():
		var tile_data = gridLayer.get_cell_tile_data(cell)
		var tileType
		tileType = tile_data.get_custom_data("tileType")
		
		MatchSettings.grid_data_p2[str(cell)] = {
			"building" : "",
			"connectedBuildings" : {}, 
			"tileType" : tileType,
		}

var last_hovered
func _process(_delta: float) -> void:
	if isMyTurn == true:
		var mouse_pos = get_global_mouse_position()
		var tile_pos = gridLayer.local_to_map(to_local(mouse_pos))
		if not last_hovered == tile_pos:
			last_hovered = tile_pos
			queue_redraw()

func _turn_changed(turn):
	queue_redraw()
	var turnn = str(turn)
	if turnn == "1":
		isMyTurn = true
		for cell in gridLayerP1.get_used_cells():
			cloudLayerP1.set_cell(0, 4, cell)
	if turnn == "Prep":
		isMyTurn = false
	if turnn == "0":
		isMyTurn = false

var old_tooltip
func _draw():
	if last_hovered == null:
		return

	if gridLayer.get_cell_source_id(last_hovered) == -1:
		return

	var tile_pos = to_local(
	gridLayer.to_global(gridLayer.map_to_local(last_hovered))
	)

	var tile_size = Vector2(gridLayer.tile_set.tile_size)

	var rect = Rect2(
	tile_pos - tile_size / 2,
		tile_size
	)
	draw_rect(rect, Color.WHITE, false, 2.0)
