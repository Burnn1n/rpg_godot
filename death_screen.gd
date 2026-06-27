extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS




func _process(delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()
	if visible and Input.is_action_just_pressed("jump"):
		get_tree().paused = false
		get_tree().reload_current_scene()
