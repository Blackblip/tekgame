extends Control
var maps = {
	"Test": {
		"Name": "Test",
		"Path": "res://Assets/Maps/TestMap.tscn",
	},
	"Test2": {
		"Name": "Test2",
		"Path": "res://Assets/Maps/TestMap.tscn",
	},
}
var playerChoosing = "p1"

@onready var chooseLabel = $Choosing

func create_buttons():
	$GridContainer/TemplateButton.visible = false
	for butt in maps:
		var map_data = maps[butt]
		var newButton = $GridContainer/TemplateButton.duplicate()
		newButton.name = map_data.Name
		newButton.text = map_data.Name
		newButton.visible = true
		$GridContainer.add_child(newButton)
		newButton.pressed.connect(choose_map.bind(map_data))
func choose_map(map_data):
	if playerChoosing == "p1":
		MatchSettings.p1_map = map_data.Name
		playerChoosing = "p2"
		chooseLabel.text = str(MatchSettings.p2_name, " is choosing")
	elif playerChoosing == "p2":
		MatchSettings.p2_map = map_data.Name
		$".".visible = false

func _ready():
	chooseLabel.text = str(MatchSettings.p1_name, " is choosing")
	
	create_buttons()
