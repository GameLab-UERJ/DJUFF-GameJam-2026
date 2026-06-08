extends Component
class_name MovementComponent


enum PossibleStates {IDLE, WALKING, GOING_DOWN, GOING_UP,TURNING_ON}


signal changed_facing(left : bool)
signal changed_state(name : PossibleStates)
signal landed


@export var enabled : bool = true
@export var speed : float = 200
@export var jump_velocity : float = 500
@export var going_down_multiplier : float = 0.2
@export var max_time_jumping : float = 0.35
@export var coyote_time : float = 0.2


var current_state : String
var _is_facing_left : bool = false
var _on_air : bool = false
var _pressed_jump : bool = false


@onready var entity : CharacterBody2D = parent as CharacterBody2D 
@onready var state_machine_player: StateMachinePlayer = $StateMachinePlayer
@onready var max_jump_timer: Timer = $MaxJumpTimer
@onready var coyote_timer: Timer = $CoyoteTimer


func _physics_process(delta: float) -> void:
	if not enabled:
		return
	handle_gravity(delta)
	handle_jump()
	handle_walk()
	update_state_machine()
	
	entity.move_and_slide()


func handle_walk() -> void:
	var direction : float = Input.get_axis("walk_left", "walk_right")
	if not direction:
		entity.velocity.x = move_toward(entity.velocity.x, 0, speed)
	else:
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


func can_jump() -> bool:
	return entity.is_on_floor() or not coyote_timer.is_stopped()


func handle_jump() -> void:
	if Input.is_action_just_released("jump"):
		max_jump_timer.stop()
		_pressed_jump = false
	if not can_jump():
		return
	if Input.is_action_just_pressed("jump"):
		max_jump_timer.start(max_time_jumping)
		_pressed_jump = true
		if Input.is_action_pressed("go_down"):
			var temp = entity.collision_mask
			entity.collision_mask = 0
			await get_tree().create_timer(0.3).timeout
			entity.collision_mask = temp
		else:
			entity.velocity.y = -500


func handle_gravity(delta : float) -> void:
	if entity.is_on_floor():
		_on_air = false
	else:
		if not _on_air:
			coyote_timer.start(coyote_time)
		_on_air = true
		if entity.velocity.y > 0:
			delta *= 2
		entity.velocity += entity.get_gravity() * delta


func update_state_machine() -> void:
	state_machine_player.set_param("on_air",_on_air)
	state_machine_player.set_param("direction_x",entity.velocity.x)
	state_machine_player.set_param("direction_y",entity.velocity.y)


func get_is_facing_left() -> bool:
	return _is_facing_left


func _on_state_machine_player_transited(from: Variant, to: Variant) -> void:
	var state : PossibleStates
	current_state = to
	
	match to:
		"Idle":
			if from == "GoingDown":
				landed.emit()
		"Walking":
			state = PossibleStates.WALKING
		"GoingDown":
			state = PossibleStates.GOING_DOWN
		"GoingUp":
			state = PossibleStates.GOING_UP
	
	changed_state.emit(state)


func _on_state_machine_player_updated(state: Variant, delta: Variant) -> void:
	match state:
		"GoingUp":
			if _pressed_jump:
				entity.velocity.y = -jump_velocity
			else:
				await create_tween().tween_property(entity,"velocity",Vector2(entity.velocity.x,0),0.08).finished
				entity.velocity.y = jump_velocity*going_down_multiplier


func _on_max_jump_timer_timeout() -> void:
	_pressed_jump = false
