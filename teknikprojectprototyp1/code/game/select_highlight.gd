
extends Node2D

@onready var turnHandler = $"../../../.."
@onready var gridLayer: TileMapLayer = get_parent()
@onready var interactions = $"../../../../../Interactions"

var previous_tile = null
var previous_grid = null

func _ready():
	turnHandler.turn_changed.connect(_turn_changed)


func _process(_delta):
	if previous_tile != interactions.selected_tile \
	or previous_grid != interactions.selected_grid:

		previous_tile = interactions.selected_tile
		previous_grid = interactions.selected_grid

		queue_redraw()


func _turn_changed(_turn):
	queue_redraw()


func _draw():
	var tile_pos = interactions.selected_tile
	var target_grid: TileMapLayer = interactions.selected_grid

	if tile_pos == null or target_grid == null:
		return

	if target_grid.get_cell_source_id(tile_pos) == -1:
		return

	# Convert the selected tile's position into this node's coordinates
	var grid_pos = target_grid.map_to_local(tile_pos)
	var global_pos = target_grid.to_global(grid_pos)
	var local_pos = to_local(global_pos)

	var tile_size = Vector2(target_grid.tile_set.tile_size)

	var rect = Rect2(
		local_pos - tile_size / 2.0,
		tile_size
	)

	# Own grid = black
	# Opponent grid = dark red
	if target_grid == gridLayer:
		draw_rect(rect, Color.BLACK, false, 2.0)
	else:
		draw_rect(rect, Color.DARK_RED, false, 2.0)
