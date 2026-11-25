
extends Node

@export var Player: AudioStreamPlayer
@export var Play_onready: bool = false

var loop_through_music = true
var index = 0
var keys = []

func _ready():
	keys = MusicList.Music.keys()
	Player.finished.connect(play_next)
	if Play_onready:
		begin_play()

func set_volume(value: float):
	Player.volume_db = linear_to_db(value / 100.0)

func resume():
	Player.stream_paused = false

func pause():
	Player.stream_paused = true

func begin_play():
	if keys.is_empty():
		return
	index = 0
	play_current()
func play_current():
	Player.stream = load(MusicList.Music[keys[index]])
	Player.play()
func play_next():
	index += 1
	if index >= keys.size():
		if loop_through_music:
			index = 0
		else:
			return
	play_current()
