extends Node2D

@onready var turnHandler = $"../../../.."
@onready var gridLayer = get_parent()

var gridLayer2: TileMapLayer
var target_grid: TileMapLayer

var isMyTurn = false
var player: int
var player_grid_data: Dictionary

var last_hovered = null
var build_mode
var cancel_mode

func _ready():
	player = get_parent().get_parent().get_meta("Player")
	if player == 1:
		player_grid_data = MatchSettings.grid_data_p1
		gridLayer2 = $"../../../../P2G/GridContainer/grid"
	elif player == 2:
		player_grid_data = MatchSettings.grid_data_p2
		gridLayer2 = $"../../../../P1G/GridContainer/grid"
	turnHandler.turn_changed.connect(_turn_changed)

func _process(_delta: float) -> void:
	if gridLayer2 == null:
		if player == 1:
			gridLayer2 = $"../../../../P2G/GridContainer/grid"
		elif player == 2:
			gridLayer2 = $"../../../../P1G/GridContainer/grid"
		return
	
	if not isMyTurn:
		return
	var mouse_pos = get_global_mouse_position()
	var local_pos1 = gridLayer.to_local(mouse_pos)
	var local_pos2 = gridLayer2.to_local(mouse_pos)
	var tile_pos1 = gridLayer.local_to_map(local_pos1)
	var tile_pos2 = gridLayer2.local_to_map(local_pos2)
	if gridLayer.get_cell_source_id(tile_pos1) != -1:
		target_grid = gridLayer
		last_hovered = tile_pos1
	elif gridLayer2.get_cell_source_id(tile_pos2) != -1:
		target_grid = gridLayer2
		last_hovered = tile_pos2
	else:
		target_grid = null
		last_hovered = null
	queue_redraw()


func _turn_changed(turn):
	isMyTurn = str(turn) == str(player - 1)
	queue_redraw()

func _draw():
	if last_hovered == null or target_grid == null:
		return
	if target_grid.get_cell_source_id(last_hovered) == -1:
		return
	var tile_pos = target_grid.map_to_local(last_hovered)
	var global_pos = target_grid.to_global(tile_pos)
	var local_pos = to_local(global_pos)
	var tile_size = Vector2(target_grid.tile_set.tile_size)
	var rect = Rect2(
		local_pos - tile_size / 2,
		tile_size
	)
	if target_grid == gridLayer2:
		if cancel_mode == true:
			draw_rect(rect, Color.RED, false, 2.0)
		else:
			draw_rect(rect, Color.DARK_RED, false, 2.0)
		return
	if cancel_mode == true:
		draw_rect(rect, Color.RED, false, 2.0)
		return
	if build_mode == true:
		var tileType = player_grid_data.get(str(last_hovered), {}).get("tileType", "Unknown")
		var broken = player_grid_data.get(str(last_hovered), {}).get("broken", "Unknown")
		var building = player_grid_data.get(str(last_hovered), {}).get("building", "Unknown")
		var scheduled = player_grid_data.get(str(last_hovered), {}).get("scheduled", "Unknown")
		if broken == true:
			draw_rect(rect, Color.RED, false, 2.0)
		if scheduled == true:
			draw_rect(rect, Color.RED, false, 2.0)
		if building != "":
			draw_rect(rect, Color.RED, false, 2.0)
		if Configs.buildable_tiles.has(tileType) and broken == false and building == "" and scheduled == false:
			draw_rect(rect, Color.GREEN, false, 2.0)
		elif not Configs.buildable_tiles.has(tileType):
			draw_rect(rect, Color.RED, false, 2.0)
		return
	draw_rect(rect, Color.BLACK, false, 2.0)
