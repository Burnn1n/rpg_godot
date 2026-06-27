extends CharacterBody3D

enum States {attack, idle, chase, die}

var state = States.idle
var hp = 15
var speed = 2
var accel = 10
var target: CharacterBody3D = null
var lastHitter: CharacterBody3D = null
var gravity = 9.8
var damage = 25
var alive = 1
var loot_gold_min = 70
var loot_gold_max = 100


@export var navAgent: NavigationAgent3D
@export var animationPlayer: AnimationPlayer

func enemy():
	pass
func attack():
	target.get_damage(damage)
	
func get_damage(damage):
	hp -= damage
	if hp > 0:
		$HurtSound.play()
	
	
func give_loot():
	if lastHitter:
		lastHitter.gold += randi_range(loot_gold_min, loot_gold_max)

	
func _process(delta: float) -> void:
	if hp <= 0:
		state = States.die
		return

func _physics_process(delta: float) -> void:
	if not alive:
		return
	if state == States.idle:
		animationPlayer.play("Idle")
		velocity = Vector3.ZERO
	elif state == States.chase:
		if target:
			look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP, true)
			navAgent.target_position = target.global_position
			var direction = navAgent.get_next_path_position() - global_position
			direction.normalized()
			velocity = velocity.lerp(direction * speed, accel * delta)
		animationPlayer.play("Walk")
		#velocity = Vector3.ZERO
	elif state == States.attack:
		if target:
			look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP, true)
		animationPlayer.play("Punch")
		
		velocity = Vector3.ZERO
	elif state == States.die:
		$DeathSound.play()
		animationPlayer.play("Die")
		alive = 0
		lastHitter = target
		velocity = Vector3.ZERO
	if not is_on_floor():
		velocity.y -= gravity * delta
	move_and_slide()


func _on_chase_area_body_entered(body: Node3D) -> void:
	if body.has_method("player"):
		target = body
		state = States.chase


func _on_chase_area_body_exited(body: Node3D) -> void:
	if body.has_method("player"):
		target = null
		state = States.idle


func _on_attack_area_body_entered(body: Node3D) -> void:
	if body.has_method("player"):
		state = States.attack


func _on_attack_area_body_exited(body: Node3D) -> void:
	if body.has_method("player"):
		state = States.chase
