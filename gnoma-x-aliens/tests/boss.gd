extends CharacterBody2D
class_name Boss


signal boss_position_updated(boss_position: Vector2)
signal boss_damaged(current_health: int, max_health: int)
signal boss_died(final_position: Vector2)
signal boss_dead_animation_finished()


enum BossState {
	DIALOGUE,
	IDLE,
	WALK,
	ATTACK_1,
	ATTACK_2,
	DEAD
}

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var damege_hitbox: CollisionShape2D = $Hitbox/Damege_Hitbox
@onready var attack_1: Area2D = $Attack_1
@onready var attack_2: Area2D = $Attack_2
@onready var attack1_collision: CollisionShape2D = $Attack_1/AttackHitbox
@onready var attack2_collision: CollisionShape2D = $Attack_2/Attack2Hitbox
@onready var wall_detector: RayCast2D = $Wall_Detector
@onready var ground_detector: RayCast2D = $Ground_Detector
@onready var fake_wall: TileMapLayer = $"../FakeWall"
@onready var door: Node2D = $"../Porta"
@onready var attack_1_sfx: AudioStreamPlayer2D = $"../Musicas_SFX/attack1"
@onready var attack_2_sfx: AudioStreamPlayer2D = $"../Musicas_SFX/attack2"
@onready var dead_sfx: AudioStreamPlayer2D = $"../Musicas_SFX/dead"
@onready var walk_sfx: AudioStreamPlayer2D = $"../Musicas_SFX/walk"
@onready var hit_sfx: AudioStreamPlayer2D = $"../Musicas_SFX/hit"
@onready var ataqueatras: Area2D = $ataqueatras
@onready var playeratras: Area2D = $Playeratras
@onready var canvas: CanvasLayer = $"../CanvasLayer"
@onready var dialogue_label: Label = $"../CanvasLayer/Dialogue_Label"

var current_state: BossState = BossState.DIALOGUE
var direction: int = -1
var start_position: Vector2
var attack_rotation: int = 0

@export var max_health: int = 60
var current_health: int = max_health

var player: Player

const WALK_SPEED: float = 90.0
const ATTACK_1_SPEED: float = 400
const ATTACK_2_SPEED: float = 35.0

var idle_timer: Timer
var walk_timer: Timer
var can_flip: bool = true

var is_dead: bool = false
var is_flashing: bool = false
var damage_cooldown: bool = false

const FLASH_DURATION: float = 0.1
const FLASH_COUNT: int = 6
const IDLE_TIME: float = 2.0
const WALK_TIME: float = 3.0
const DAMAGE_COOLDOWN_TIME: float = 0.3

var dialogue_index: int = 0
var dialogue_finished: bool = false

# Variáveis para as áreas de detecção
var player_in_atras: bool = false
var player_in_ataqueatras: bool = false

@export var dialogue_list: Array[String] = [
	"Você ousou me desafiar?",
	"Eu sou o guardião deste lugar!",
	"Ninguém nunca me derrotou...",
	"Prepare-se para a batalha!"
]

func _ready() -> void:
	start_position = global_position
	current_health = max_health
	
	idle_timer = Timer.new()
	idle_timer.one_shot = true
	idle_timer.timeout.connect(_on_idle_timer_timeout)
	add_child(idle_timer)
	
	walk_timer = Timer.new()
	walk_timer.one_shot = true
	walk_timer.timeout.connect(_on_walk_timer_timeout)
	add_child(walk_timer)
	
	hitbox.area_entered.connect(_on_hitbox_area_entered)
	attack_1.body_entered.connect(_on_attack_area_body_entered)
	attack_1.body_exited.connect(_on_attack_area_body_exited)
	attack_2.body_entered.connect(_on_attack_area_body_entered)
	attack_2.body_exited.connect(_on_attack_area_body_exited)
	
	# Conecta as áreas de detecção
	playeratras.body_entered.connect(_on_player_atras_entered)
	playeratras.body_exited.connect(_on_player_atras_exited)
	ataqueatras.body_entered.connect(_on_ataque_atras_entered)
	ataqueatras.body_exited.connect(_on_ataque_atras_exited)
	
	anim.animation_finished.connect(_on_animation_finished)
	anim.frame_changed.connect(_on_frame_changed)
	
	_clear_attacks()
	_start_dialogue()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if current_state != BossState.DIALOGUE and dialogue_finished:
		_check_back_areas()
	
	match current_state:
		BossState.DIALOGUE:
			velocity = Vector2.ZERO
		BossState.IDLE:
			velocity = Vector2.ZERO
		BossState.WALK:
			_handle_walk_movement()
		BossState.ATTACK_1:
			_handle_attack1_movement()
		BossState.ATTACK_2:
			velocity = Vector2.ZERO
		BossState.DEAD:
			velocity = Vector2.ZERO
	
	move_and_slide()

func _start_dialogue() -> void:
	current_state = BossState.DIALOGUE
	anim.play("idle")
	if canvas:
		canvas.visible = true
	get_tree().paused = true
	dialogue_index = 0
	
	if dialogue_list.size() > 0:
		if dialogue_label:
			dialogue_label.text = dialogue_list[dialogue_index]
		dialogue_index += 1
	else:
		_end_dialogue()

func _end_dialogue() -> void:
	if canvas:
		canvas.visible = false
	get_tree().paused = false
	dialogue_finished = true
	dialogue_index = 0
	go_to_walk_state()

func _input(event: InputEvent) -> void:
	if not dialogue_finished and current_state == BossState.DIALOGUE:
		if event.is_action_pressed("interact"):
			if dialogue_index < dialogue_list.size():
				dialogue_label.text = dialogue_list[dialogue_index]
				dialogue_index += 1
			else:
				_end_dialogue()


# Callbacks das áreas de detecção
func _on_player_atras_entered(body: Node2D) -> void:
	if body is Player:
		player_in_atras = true

func _on_player_atras_exited(body: Node2D) -> void:
	if body is Player:
		player_in_atras = false

func _on_ataque_atras_entered(body: Node2D) -> void:
	if body is Player:
		player_in_ataqueatras = true

func _on_ataque_atras_exited(body: Node2D) -> void:
	if body is Player:
		player_in_ataqueatras = false

func _check_back_areas() -> void:
	if is_dead:
		return
	
	if current_state == BossState.ATTACK_1 or current_state == BossState.ATTACK_2:
		return
	
	# AMBOS: vira E ataca com attack 2
	if player_in_atras and player_in_ataqueatras:
		_flip()
		go_to_attack2_state()
	# SÓ playeratras: apenas vira
	elif player_in_atras:
		_flip()

func _handle_walk_movement() -> void:
	if not can_flip:
		return
	velocity.x = WALK_SPEED * direction
	if wall_detector.is_colliding():
		_flip()
	elif not ground_detector.is_colliding():
		_flip()

func _handle_attack1_movement() -> void:
	if anim.frame <= 4:
		velocity.x = 0
		return
	
	if not can_flip:
		return
	
	if anim.frame >= 5 and anim.frame <= 11:
		velocity.x = ATTACK_1_SPEED * direction
	elif anim.frame >= 12 and anim.frame <= 16:
		velocity.x = WALK_SPEED * direction
	else:
		velocity.x = WALK_SPEED * direction
	
	if wall_detector.is_colliding():
		_flip()
	elif not ground_detector.is_colliding():
		_flip()

func _flip() -> void:
	if not can_flip:
		return
	can_flip = false
	direction *= -1
	scale.x *= -1
	await get_tree().create_timer(0.2).timeout
	can_flip = true

func _on_frame_changed() -> void:
	match current_state:
		BossState.ATTACK_1:
			if anim.frame >= 5 and anim.frame <= 11:
				_show_attack1()
			else:
				_hide_attack1()
		BossState.ATTACK_2:
			if anim.frame >= 4 and anim.frame <= 8:
				_show_attack2()
			else:
				_hide_attack2()

func _show_attack1() -> void:
	attack_1.set_deferred("monitoring", true)
	attack_1.set_deferred("monitorable", true)
	attack_1.visible = true
	attack1_collision.set_deferred("disabled", false)
	attack1_collision.visible = true

func _hide_attack1() -> void:
	attack_1.set_deferred("monitoring", false)
	attack_1.set_deferred("monitorable", false)
	attack_1.visible = false
	attack1_collision.set_deferred("disabled", true)
	attack1_collision.visible = false

func _show_attack2() -> void:
	attack_2.set_deferred("monitoring", true)
	attack_2.set_deferred("monitorable", true)
	attack_2.visible = true
	attack2_collision.set_deferred("disabled", false)
	attack2_collision.visible = true

func _hide_attack2() -> void:
	attack_2.set_deferred("monitoring", false)
	attack_2.set_deferred("monitorable", false)
	attack_2.visible = false
	attack2_collision.set_deferred("disabled", true)
	attack2_collision.visible = false

func go_to_idle_state() -> void:
	walk_sfx.stop()
	current_state = BossState.IDLE
	anim.play("idle")
	_clear_attacks()
	velocity = Vector2.ZERO
	walk_timer.stop()
	idle_timer.start(IDLE_TIME)

func go_to_walk_state() -> void:
	current_state = BossState.WALK
	anim.play("walk")
	walk_sfx.play()
	_clear_attacks()
	can_flip = true
	velocity.x = WALK_SPEED * direction
	walk_timer.start(WALK_TIME)

func go_to_attack1_state() -> void:
	walk_sfx.stop()
	current_state = BossState.ATTACK_1
	anim.play("attack_1")
	attack_1_sfx.play()
	can_flip = true
	_clear_attacks()
	velocity = Vector2.ZERO

func go_to_attack2_state() -> void:
	walk_sfx.stop()
	current_state = BossState.ATTACK_2
	anim.play("attack_2")
	attack_2_sfx.play()
	_clear_attacks()
	velocity = Vector2.ZERO

func go_to_dead_state() -> void:
	walk_sfx.stop()
	fake_wall.queue_free()
	dead_sfx.play()
	current_state = BossState.DEAD
	is_dead = true
	anim.play("dead")
	_clear_attacks()
	velocity = Vector2.ZERO
	idle_timer.stop()
	walk_timer.stop()
	player = null
	boss_died.emit(global_position)

func _clear_attacks() -> void:
	attack_1.set_deferred("monitoring", false)
	attack_1.set_deferred("monitorable", false)
	attack_1.visible = false
	attack1_collision.set_deferred("disabled", true)
	attack1_collision.visible = false
	
	attack_2.set_deferred("monitoring", false)
	attack_2.set_deferred("monitorable", false)
	attack_2.visible = false
	attack2_collision.set_deferred("disabled", true)
	attack2_collision.visible = false

func _on_attack_area_body_entered(body: Node2D) -> void:
	player = body as Player
	if player and not is_dead:
		player.take_damage()

func _on_attack_area_body_exited(_body: Node2D) -> void:
	player = null

func take_damage(damage_amount: int = 1) -> void:
	if is_dead:
		return
	
	if current_state == BossState.DIALOGUE:
		return
	
	if damage_cooldown:
		return
	
	current_health -= damage_amount
	damage_cooldown = true
	
	hit_sfx.play()
	
	print("🎯 BOSS TOMOU DANO! Vida: ", current_health, "/", max_health)
	
	boss_damaged.emit(current_health, max_health)
	
	if current_health <= 0:
		current_health = 0
		die()
		return
	
	_flash_effect()
	
	await get_tree().create_timer(DAMAGE_COOLDOWN_TIME).timeout
	damage_cooldown = false

func die() -> void:
	go_to_dead_state()

func _flash_effect() -> void:
	is_flashing = true
	var tween: Tween = create_tween()
	for i in range(FLASH_COUNT):
		tween.tween_callback(func(): anim.modulate = Color.RED)
		tween.tween_interval(FLASH_DURATION)
		tween.tween_callback(func(): anim.modulate = Color.WHITE)
		tween.tween_interval(FLASH_DURATION)
	tween.tween_callback(func(): 
		anim.modulate = Color.WHITE
		is_flashing = false
	)

func _on_idle_timer_timeout() -> void:
	if current_state == BossState.IDLE:
		go_to_walk_state()

func _on_walk_timer_timeout() -> void:
	if current_state == BossState.WALK:
		if attack_rotation == 0:
			attack_rotation = 1
			go_to_attack1_state()
		else:
			attack_rotation = 0
			go_to_attack2_state()

func _on_animation_finished() -> void:
	if current_state == BossState.ATTACK_1:
		_clear_attacks()
		go_to_walk_state()
	elif current_state == BossState.ATTACK_2:
		_clear_attacks()
		go_to_walk_state()
	elif current_state == BossState.DEAD:
		_open_door()
		queue_free()

func _open_door() -> void:
	boss_dead_animation_finished.emit()
	
	if door:
		door.queue_free()
		print("PORTA ABERTA!")

func _on_hitbox_area_entered(area: Area2D) -> void:
	take_damage(1)

func heal(amount: int) -> void:
	current_health = min(current_health + amount, max_health)
	boss_damaged.emit(current_health, max_health)

func get_health() -> int:
	return current_health

func get_max_health() -> int:
	return max_health

func get_health_percent() -> float:
	return float(current_health) / float(max_health)

func reset() -> void:
	_clear_attacks()
	velocity = Vector2.ZERO
	is_dead = false
	is_flashing = false
	can_flip = true
	attack_rotation = 0
	damage_cooldown = false
	player = null
	player_in_atras = false
	player_in_ataqueatras = false
	dialogue_finished = false
	dialogue_index = 0
	canvas.visible = false
	get_tree().paused = false
	current_health = max_health
	anim.modulate = Color.WHITE
	global_position = start_position
	_start_dialogue()
