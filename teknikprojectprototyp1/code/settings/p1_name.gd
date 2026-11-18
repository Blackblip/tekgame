extends LineEdit

@onready var lineEdit = $"."
func _ready() -> void:
	lineEdit.text_changed.connect(_on_line_edit_changed)

func _on_line_edit_changed(name) -> void:
	MatchSettings.p1_name = str(name)
