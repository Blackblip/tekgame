extends Button

func _ready() -> void:
	$".".grab_focus()
	$".".pressed.connect(_button_pressed)

func _button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
