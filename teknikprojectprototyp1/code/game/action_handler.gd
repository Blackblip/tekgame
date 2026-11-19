extends Node2D
@onready var player = $GridContainer.get_meta("Player")
@onready var turnHandler = $".."

var schedule = {
	
}

func _ready():
	turnHandler.turn_changed.connect(_turn_changed)

func _turn_changed(turn):
	if str(turn) == "Prep":
		perform_scheduled_actions()

func perform_scheduled_actions():
	for a in schedule:
		var aa = schedule[a]
		if aa.Type == "Build":
			print("building scheduled for creation is being made")
			schedule[a] = null
func schedule_build(building, tile_pos):
	schedule[building.Name] = {
		"Type": "Build",
		"Building": building.Name,
		"tile_pos": tile_pos,
	}
