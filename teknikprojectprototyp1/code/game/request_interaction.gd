extends TileMapLayer
@onready var player = $".".get_parent().get_meta("Player")
@onready var gridLayer = $"."
@onready var turnHandler = $"../../.."

var isMyTurn

func _ready():
	turnHandler.turn_changed.connect(_turn_changed)
func _turn_changed(turn):
	$"../../../../Interactions".update_scroll(null)
	var turnn = str(turn)
	if turnn == str(player - 1):
		isMyTurn = true
		queue_redraw()
	else:
		isMyTurn = false
		queue_redraw()

func _input(event):
	var last_hovered = $TileMapLayer.last_hovered
	var mouse_pos = gridLayer.to_local(get_global_mouse_position())
	var tile_pos = gridLayer.local_to_map(mouse_pos)
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if isMyTurn == true:
				if last_hovered == tile_pos:
					if gridLayer.get_cell_source_id(last_hovered) != -1:
						$"../../../../Interactions".show_actions_for_tile(tile_pos, player)
