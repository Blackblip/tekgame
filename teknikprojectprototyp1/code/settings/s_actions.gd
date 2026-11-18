extends SpinBox
@onready var spin_box: SpinBox = $"."

func _ready() -> void:
	spin_box.value = MatchSettings.starting_actions
	spin_box.value_changed.connect(_on_spinbox_value_changed)

func _on_spinbox_value_changed(val: float) -> void:
	MatchSettings.starting_actions = int(val)
