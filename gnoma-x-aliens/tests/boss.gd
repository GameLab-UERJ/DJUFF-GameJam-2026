extends CharacterBody2D

signal boss_died

# Enum para os estados do Boss
enum BossState {
	IDLE,
	WALK,
	ATTACK_1,
	ATTACK_2,
	DEAD
}


# Referências aos nós da cena
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var damege_hitbox: CollisionShape2D = $Hitbox/Damege_Hitbox
@onready var attack_1: Area2D = $Attack_1
@onready var attack_2: Area2D = $Attack_2
@onready var attack1_collision: CollisionShape2D = $Attack_1/AttackHitbox
@onready var attack2_collision: CollisionShape2D = $Attack_2/Attack2Hitbox
@onready var wall_detector: RayCast2D = $Wall_Detector
@onready var ground_detector: RayCast2D = $Ground_Detector
@onready var dead_timer: Timer = $DeadTimer  # Timer para morte automática

# Variáveis de estado
var current_state: BossState = BossState.IDLE
var direction: int = -1
var start_position: Vector2
var attack_rotation: int = 0

# Sistema de vida
var max_health: int = 60  # Vida máxima do boss
var current_health: int = max_health  # Vida atual

# Constantes de movimento
const WALK_SPEED: float = 50.0
const ATTACK_1_SPEED: float = 100.0
const ATTACK_2_SPEED: float = 25.0

# Timers
var idle_timer: Timer
var walk_timer: Timer
var can_flip: bool = true

# Variáveis de controle
var can_take_damage: bool = false
var is_dead: bool = false
var is_flashing: bool = false
var damage_cooldown: bool = false

# Constantes
const FLASH_DURATION: float = 0.1
const FLASH_COUNT: int = 6
const IDLE_TIME: float = 2.0
const WALK_TIME: float = 3.0
const DAMAGE_COOLDOWN_TIME: float = 0.5

func _ready() -> void:
	start_position = global_position
	current_health = max_health  # Inicia com 60 de vida
	
	# Timer do IDLE
	idle_timer = Timer.new()
	idle_timer.one_shot = true
	idle_timer.timeout.connect(_on_idle_timer_timeout)
	add_child(idle_timer)
	
	# Timer do WALK
	walk_timer = Timer.new()
	walk_timer.one_shot = true
	walk_timer.timeout.connect(_on_walk_timer_timeout)
	add_child(walk_timer)
	
	# Conecta sinais
	hitbox.area_entered.connect(_on_hitbox_area_entered)
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	anim.animation_finished.connect(_on_animation_finished)
	anim.frame_changed.connect(_on_frame_changed)
	
	# Conecta o DeadTimer se ele existir na cena
	if dead_timer:
		dead_timer.timeout.connect(_on_dead_timer_timeout)
		dead_timer.start()  # Inicia a contagem para morte automática
		print("DeadTimer iniciado! Boss morrerá em ", dead_timer.wait_time, " segundos")
	
	# Garante que TUDO comece invisível e desligado
	_clear_attacks()
	
	# Estado inicial
	go_to_idle_state()

func _physics_process(delta: float) -> void:
	# Gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Estados
	match current_state:
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

# Sistema de movimento
func _handle_walk_movement() -> void:
	if not can_flip:
		return
	
	velocity.x = WALK_SPEED * direction
	
	if wall_detector.is_colliding():
		_flip()
	elif not ground_detector.is_colliding():
		_flip()

func _handle_attack1_movement() -> void:
	# Fica parado nos frames 0 a 4
	if anim.frame <= 4:
		velocity.x = 0
		return
	
	# Começa a se mover a partir do frame 5
	if not can_flip:
		return
	
	velocity.x = ATTACK_1_SPEED * direction
	
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

# Controle de dano baseado nos frames
func _on_frame_changed() -> void:
	match current_state:
		BossState.ATTACK_1:
			if anim.frame >= 5 and anim.frame <= 9:
				_show_attack1()
			else:
				_hide_attack1()
		
		BossState.ATTACK_2:
			if anim.frame >= 4 and anim.frame <= 8:
				_show_attack2()
			else:
				_hide_attack2()

# Funções para mostrar/esconder ataques
func _show_attack1() -> void:
	attack_1.monitoring = true
	attack_1.monitorable = true
	attack_1.visible = true
	attack1_collision.disabled = false
	attack1_collision.visible = true

func _hide_attack1() -> void:
	attack_1.monitoring = false
	attack_1.monitorable = false
	attack_1.visible = false
	attack1_collision.disabled = true
	attack1_collision.visible = false

func _show_attack2() -> void:
	attack_2.monitoring = true
	attack_2.monitorable = true
	attack_2.visible = true
	attack2_collision.disabled = false
	attack2_collision.visible = true

func _hide_attack2() -> void:
	attack_2.monitoring = false
	attack_2.monitorable = false
	attack_2.visible = false
	attack2_collision.disabled = true
	attack2_collision.visible = false

# Transições de estado
func go_to_idle_state() -> void:
	current_state = BossState.IDLE
	anim.play("idle")
	can_take_damage = false
	_clear_attacks()
	velocity = Vector2.ZERO
	walk_timer.stop()
	idle_timer.start(IDLE_TIME)

func go_to_walk_state() -> void:
	current_state = BossState.WALK
	anim.play("walk")
	can_take_damage = true
	_clear_attacks()
	can_flip = true
	velocity.x = WALK_SPEED * direction
	walk_timer.start(WALK_TIME)

func go_to_attack1_state() -> void:
	current_state = BossState.ATTACK_1
	anim.play("attack_1")
	can_take_damage = false
	can_flip = true
	_clear_attacks()
	velocity = Vector2.ZERO

func go_to_attack2_state() -> void:
	current_state = BossState.ATTACK_2
	anim.play("attack_2")
	can_take_damage = false
	_clear_attacks()
	velocity = Vector2.ZERO

func go_to_dead_state() -> void:
	current_state = BossState.DEAD
	is_dead = true
	anim.play("dead")
	can_take_damage = false
	_clear_attacks()
	velocity = Vector2.ZERO
	idle_timer.stop()
	walk_timer.stop()
	
	# Para o DeadTimer quando morrer
	if dead_timer:
		dead_timer.stop()

# Limpa TUDO
func _clear_attacks() -> void:
	# Attack 1
	attack_1.monitoring = false
	attack_1.monitorable = false
	attack_1.visible = false
	attack1_collision.disabled = true
	attack1_collision.visible = false
	
	# Attack 2
	attack_2.monitoring = false
	attack_2.monitorable = false
	attack_2.visible = false
	attack2_collision.disabled = true
	attack2_collision.visible = false

# Sistema de dano
func take_damage(damage_amount: int = 1) -> void:
	if not can_take_damage or is_dead or is_flashing or damage_cooldown:
		return
	
	current_health -= damage_amount
	
	if current_health <= 0:
		current_health = 0
		die()
		return
	
	damage_cooldown = true
	
	_start_flash_effect()
	go_to_idle_state()
	
	await get_tree().create_timer(DAMAGE_COOLDOWN_TIME).timeout
	damage_cooldown = false

func die() -> void:
	print("Boss morreu! Vida: ", current_health, "/", max_health)
	go_to_dead_state()

func _start_flash_effect() -> void:
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

# DeadTimer - Morte automática para teste
func _on_dead_timer_timeout() -> void:
	print("DeadTimer estourou! Boss vai morrer automaticamente!")
	# Força a morte do boss
	current_health = 0
	die()

# Timers
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

# Animação finalizada
func _on_animation_finished() -> void:
	if current_state == BossState.ATTACK_1:
		_clear_attacks()
		go_to_walk_state()
	elif current_state == BossState.ATTACK_2:
		_clear_attacks()
		go_to_walk_state()
	elif current_state == BossState.DEAD:
		print("Animação de morte finalizada. Removendo boss da cena...")
		boss_died.emit()
		queue_free()

# Colisões
func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_attack"):
		take_damage(1)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		take_damage(1)
		# Causar dano ao jogador também
		# body.take_damage(1)

# Funções úteis
func heal(amount: int) -> void:
	current_health = min(current_health + amount, max_health)

func get_health() -> int:
	return current_health

func get_max_health() -> int:
	return max_health

func get_health_percent() -> float:
	return float(current_health) / float(max_health)

# Reset do boss
func reset() -> void:
	_clear_attacks()
	velocity = Vector2.ZERO
	is_dead = false
	is_flashing = false
	can_flip = true
	attack_rotation = 0
	damage_cooldown = false
	current_health = max_health
	anim.modulate = Color.WHITE
	global_position = start_position
	
	# Reinicia o DeadTimer se existir
	if dead_timer:
		dead_timer.start()
		print("DeadTimer reiniciado!")
	
	go_to_idle_state()
