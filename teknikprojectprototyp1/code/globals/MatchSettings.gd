extends Node

var cost_multiplier: float = 1
var starting_actions: int = 2
var total_turns: int = 30
var p1_map: String = ""
var p2_map: String = ""
var p1_name: String = "Player1"
var p2_name: String = "Player2"

var turn_count: int = 0
var turns_left: int = total_turns

var scoreP1: int = 0
var scoreP2: int = 0
var actionsPerTurnP1: int = 0
var actionsPerTurnP2: int = 0
var actionsLeftP1: int = 0
var actionsLeftP2: int = 0

var grid_data_p1 = {}
var grid_data_p1_p2_perspective = {}
var grid_data_p2 = {}
var grid_data_p2_p1_perspective = {}

var tile_types = {
	"Cloud": [4, Vector2i(0, 0)],
	"Grass": [0, Vector2i(0, 0)],
	"Mountain": [2, Vector2i(0, 0)],
	"Test": [3, Vector2i(0,0)]
}
