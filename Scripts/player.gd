extends CharacterBody3D


const SPEED = 10.0
const JUMP_VELOCITY = 4.5

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var sensitivity = 0.003
var onCooldown = 2
var gold = 0
var hp = 50
var maxHp = 50
var damage = 10
var target = []

@onready var camera = $FirstPerson
@onready var hpBar = $HUD/HP
@onready var goldLabel = $HUD/Gold 

func _ready() -> void:
	$FirstPerson.current = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	hpBar.max_value = maxHp
	
	
func update_hud():
	hpBar.value = hp
	goldLabel.text = str(gold)
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(70))
		
func _process(delta: float) -> void:
	update_hud()
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()

func _physics_process(delta: float) -> void:
	_switch_view()
	attack()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UwdsI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _switch_view():
	if Input.is_action_just_pressed("switch"):
		if camera == $FirstPerson:
			camera = $Head
			$Head/ThirdPerson.current = true
		else:
			camera =  $FirstPerson
			$FirstPerson.current = true
			
func attack():
	if Input.is_action_just_pressed("attack") and not $AnimationPlayer.is_playing():
		$SwordSwingSound.play()
		$AnimationPlayer.play("SwordSwing")
	
func deal_damage():
	if target:
		for l in target:
			l.get_damage(damage)

func get_damage(damage):
	hp -= damage
	if $HurtSound.playing:
		return
	if hp > 0:
		var hurt_sounds = [
			"res://Audio/human/hurt1.MP3",
			"res://Audio/human/hurt2.MP3",
			"res://Audio/human/hurt3.MP3",
			"res://Audio/human/hurt4.MP3",
			"res://Audio/human/hurt5.MP3",
			"res://Audio/human/hurt6.MP3",
			"res://Audio/human/hurt7.MP3",
		]
		$HurtSound.stream = load(hurt_sounds[randi() % hurt_sounds.size()])
		$HurtSound.play()
	#death
	else:
		die()
		
		
func die():
	get_parent().get_node("DeathSound").play()
	get_tree().paused = true
	var deathScreen: CanvasLayer = get_parent().get_node("DeathScreen")
	deathScreen.visible = true
		

func player():
	pass


func _on_attack_zone_body_entered(body: Node3D) -> void:
	if body.has_method("enemy"):
		target.append(body)



func _on_attack_zone_body_exited(body: Node3D) -> void:
	if body.has_method("enemy"):
		target.erase(body)
	pass # Replace with function body.
