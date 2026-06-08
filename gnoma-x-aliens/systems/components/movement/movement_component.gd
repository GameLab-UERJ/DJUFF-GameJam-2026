extends Component
class_name MovementComponent


enum PossibleStates {IDLE, WALKING, GOING_DOWN, GOING_UP,TURNING_ON}


signal changed_facing(left : bool)
signal changed_state(name : PossibleStates)
signal landed


@export var enabled : bool = true
@export var speed : float = 150.0
@export var jump_velocity : float = -500


var current_state : String
var _is_facing_left : bool = false
var _on_air : bool = false
var _is_walking : bool = false


@onready var entity : CharacterBody2D = parent as CharacterBody2D 
@onready var state_machine_player: StateMachinePlayer = $StateMachinePlayer


func _physics_process(delta: float) -> void:
	if not enabled:
		return
	handle_gravity(delta)
	handle_jump()
	handle_walk()
	state_machine_player.set_param("on_air",_on_air)
	state_machine_player.set_param("direction_x",entity.velocity.x)
	state_machine_player.set_param("direction_y",entity.velocity.y)
	
	entity.move_and_slide()


func handle_walk() -> void:
	var direction : float = Input.get_axis("walk_left", "walk_right")
	if not direction:
		entity.velocity.x = move_toward(entity.velocity.x, 0, speed)
		_is_walking = false
	else:
		if not (_is_walking or _on_air):
			_is_walking = true
		
		if direction < 0 and not _is_facing_left:
			_is_facing_left = not _is_facing_left
			changed_facing.emit(_is_facing_left)
		elif direction > 0 and _is_facing_left:
			_is_facing_left = not _is_facing_left
			changed_facing.emit(_is_facing_left)
		entity.velocity.x = direction * speed


func is_idle() -> bool:
	return not entity.velocity


func start_turn_on() -> void:
	state_machine_player.set_trigger("start_turn_on")


func end_turn_on() -> void:
	state_machine_player.set_trigger("end_turn_on")


func handle_jump() -> void:
	if not entity.is_on_floor():
		return
	if Input.is_action_just_pressed("jump"):
		if Input.is_action_pressed("go_down"):
			_on_air = true
			var temp = entity.collision_mask
			entity.collision_mask = 0
			await get_tree().create_timer(0.2).timeout
			entity.collision_mask = temp
		else:
			entity.velocity.y = jump_velocity
			entity.velocity.x *= 1.25
			_on_air = true


func handle_gravity(delta : float) -> void:
	if entity.is_on_floor():
		_on_air = false
	else:
		_on_air = true
		if entity.velocity.y > 0:
			delta *= 2
		entity.velocity += entity.get_gravity() * delta


func get_is_facing_left() -> bool:
	return _is_facing_left


func _on_state_machine_player_transited(from: Variant, to: Variant) -> void:
	var state : PossibleStates
	current_state = to
	
	match to:
		"Idle":
			state = PossibleStates.IDLE
			if from == "GoingDown":
				landed.emit()
		"Walking":
			state = PossibleStates.WALKING
		"GoingDown":
			state = PossibleStates.GOING_DOWN
		"GoingUp":
			state = PossibleStates.GOING_UP
	
	changed_state.emit(state)
