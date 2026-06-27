extends Node3D

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()
	var deathScreen: CanvasLayer = $DeathScreen
	print(deathScreen.visible)
	print(Input.is_action_just_pressed("jump"))
	if deathScreen.visible and Input.is_action_just_pressed("jump"):
		deathScreen.visible = false
		get_tree().paused = false
		get_tree().reload_current_scene()
