extends SpinBox
@onready var spin_box: SpinBox = $"."

func _ready() -> void:
	spin_box.value = MatchSettings.cost_multiplier
	spin_box.value_changed.connect(_on_spinbox_value_changed)

func _on_spinbox_value_changed(val: float) -> void:
	MatchSettings.cost_multiplier = float(val)
