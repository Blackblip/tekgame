extends Node2D

@onready var turnHandler = $"../../../.."
@onready var gridLayer = $".".get_parent()

var player: int
var player_grid_data: Dictionary

func _ready():
	turnHandler.turn_changed.connect(_turn_changed)
func _turn_changed(turn):
	queue_redraw()

func _draw():
	var tile_pos = $"../../../../../Interactions".selected_tile
	if tile_pos == null:
		return

	var local_pos = gridLayer.map_to_local(tile_pos)
	var global_pos = gridLayer.to_global(local_pos)
	local_pos = to_local(global_pos)
	var tile_size = Vector2(gridLayer.tile_set.tile_size)
	var rect = Rect2(
		local_pos - tile_size / 2.0,
		tile_size
	)
	draw_rect(rect, Color.WHITE, false, 2.0)
