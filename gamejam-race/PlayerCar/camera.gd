extends Camera2D


func _ready() -> void:
	if is_multiplayer_authority():
		make_current()
