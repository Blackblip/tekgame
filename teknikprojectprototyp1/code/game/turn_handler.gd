extends Node
class_name TurnHandler

@onready var UI = $"../CenterContainer/UI"
@onready var endButton = $"../CenterContainer/UI/EndTurn"
@onready var startButton = $"../CenterContainer/UI/StartTurn"
@onready var turnsLeftUI = $"../CenterContainer/UI/TurnsLeft"
@onready var actionsUI = $"../CenterContainer/UI/PActions"

@onready var p1Node = $P1G
@onready var player1Name = $P1G/pName
@onready var p2Node = $P2G
@onready var player2Name = $P2G/pName

enum Turn { PLAYER1, PLAYER2 }
var current_turn: Turn
var isPrep = true

var turns_left = 0

signal turn_changed(new_turn)

func _ready():
	MatchSettings.actionsPerTurnP1 = MatchSettings.starting_actions
	MatchSettings.actionsPerTurnP2 = MatchSettings.starting_actions
	
	player1Name.text = str(MatchSettings.p1_name)
	player2Name.text = str(MatchSettings.p2_name)
	
	UI.visible = true
	
	turns_left = MatchSettings.total_turns
	turnsLeftUI.text = str(turns_left)
	
	prepare_turn()
	endButton.visible = false
	startButton.pressed.connect(_start_turn_pressed)
	endButton.pressed.connect(_end_turn_pressed)

func _start_turn_pressed():
	start_turn()
func _end_turn_pressed():
	if turns_left >= 1:
		next_turn()
	if turns_left <= 0:
		print("game ended")

func prepare_turn():
	isPrep = true
	turn_changed.emit("Prep")
	
	match current_turn:
		Turn.PLAYER1:
			#p1Node.visible = false
			#p2Node.visible = false
			
			actionsUI.text = "?"
			
			startButton.visible = true
			endButton.visible = false
		Turn.PLAYER2:
			#p1Node.visible = false
			#p2Node.visible = false
			
			actionsUI.text = "?"
			
			startButton.visible = true
			endButton.visible = false

var loop_count = 1
func next_turn():
	loop_count += 1
	if loop_count >= 3:
		turns_left = turns_left - 1
		MatchSettings.turns_left = turns_left
		loop_count = 1
	turnsLeftUI.text = str(turns_left)
	
	match current_turn:
		Turn.PLAYER1:
			current_turn = Turn.PLAYER2
			prepare_turn()
		Turn.PLAYER2:
			current_turn = Turn.PLAYER1
			prepare_turn()

func start_turn():
	isPrep = false
	turn_changed.emit(current_turn)
	
	match current_turn:
		Turn.PLAYER1:
			MatchSettings.actionsLeftP1 = MatchSettings.actionsPerTurnP1
			actionsUI.text = str(MatchSettings.actionsLeftP1)
			
			#p1Node.visible = true
			
			endButton.visible = true
			startButton.visible = false
		Turn.PLAYER2:
			MatchSettings.actionsLeftP2 = MatchSettings.actionsPerTurnP2
			actionsUI.text = str(MatchSettings.actionsLeftP2)
			
			#p2Node.visible = true
			
			startButton.visible = false
			endButton.visible = true
