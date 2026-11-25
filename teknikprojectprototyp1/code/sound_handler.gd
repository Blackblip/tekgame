extends Node

@export var max_players: int = 10
@onready var TurnHandler = $"../TurnHandler"

var available_players: Array[AudioStreamPlayer] = []

func _ready():
	for i in range(max_players):
		var player = AudioStreamPlayer.new()
		add_child(player)
		available_players.append(player)
	TurnHandler.turn_changed.connect(turn_changed.bind())

func turn_changed(turn):
	var player = $".".get_meta("Player")
	
	if str(turn) == str(player):
		resume_sounds()
	else:
		pause_sounds()
func pause_sounds():
	for player in available_players:
		player.stream_paused = true
func resume_sounds():
	for player in available_players:
		player.stream_paused = false

func play_sound(path: String):
	for player in available_players:
		if !player.playing:
			player.stream = SoundList.SFX[path]
			player.play()
			return
