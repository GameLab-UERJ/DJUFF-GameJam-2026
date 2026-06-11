extends Enemy
class_name SwordEnemy


const INITIAL_SPRITES_POSITION : Vector2 = Vector2(0,-4)
const SHIFTED_SPRITES_POSITION_LEFT : Vector2 = Vector2(-20,-36)
const SHIFTED_SPRITES_POSITION_RIGHT: Vector2 = Vector2(20,-36)


@export var ignore_positioning : bool = false
@export var damage_player_range : Vector2i = Vector2i.ONE*-1
@export var move_speed : float = 50.0

var detected_player : Player
var player : Player
var damaging_player : bool
var wants_to_return : bool = false
var is_dead : bool = false
var can_flip : bool = true
var is_moving : bool = true


var is_facing_right : bool = false:
	set(value):
		is_facing_right = value
		if sprites:
			sprites.flip_h = is_facing_right
			if not is_facing_right:
				damage_collision_shape.position.x = -40.5
				position_sprites(sprites.animation)
			else:
				damage_collision_shape.position.x = 40.5
				position_sprites(sprites.animation)
		_update_ground_detectors()  # NOVO: atualiza qual detector usar

@onready var sprites: AnimatedSprite2D = $Sprites
@onready var damage_collision_shape: CollisionShape2D = $DamageArea/DamageCollisionShape
@onready var alert_sfx: AudioStreamPlayer2D = $SoundEffects/AlertSfx
@onready var transform_sfx: AudioStreamPlayer2D = $SoundEffects/TransformSfx
@onready var spawn_sfx: AudioStreamPlayer2D = $SoundEffects/SpawnSfx
@onready var attack_sfx: AudioStreamPlayer2D = $SoundEffects/AttackSfx
@onready var dead_sfx: AudioStreamPlayer2D = $SoundEffects/dead_sfx
@onready var wall_detector: RayCast2D = $Wall_Detector
@onready var ground_detector: RayCast2D = $Ground_Detector
@onready var ground_detector_2: RayCast2D = $Ground_Detector2


func _ready() -> void:
	is_facing_right = is_facing_right
	play_animation("walk")


func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	update_facing()
	
	if is_moving and not damaging_player:
		_move_and_check_collisions(delta)


# NOVO: Ativa/desativa os ground detectors conforme a direção
func _update_ground_detectors() -> void:
	if is_facing_right:
		# Indo para direita: usa detector 1, desabilita detector 2
		ground_detector.enabled = true
		ground_detector_2.enabled = false
	else:
		# Indo para esquerda: usa detector 2, desabilita detector 1
		ground_detector.enabled = false
		ground_detector_2.enabled = true


func update_facing() -> void:
	if damaging_player:
		return
	if detected_player:
		if global_position.direction_to(detected_player.global_position).x < 0:
			is_facing_right = false
		else:
			is_facing_right = true


func _move_and_check_collisions(_delta: float) -> void:
	if not can_flip:
		return
	
	var direction = 1 if is_facing_right else -1
	position.x += direction * move_speed * _delta
	
	# Força atualização do detector ativo
	var active_ground = ground_detector if is_facing_right else ground_detector_2
	active_ground.force_raycast_update()
	
	if wall_detector.is_colliding():
		_flip()
		return
	
	if not active_ground.is_colliding():
		_flip()


func _flip() -> void:
	if not can_flip:
		return
	
	can_flip = false
	is_facing_right = not is_facing_right
	sprites.flip_h = is_facing_right
	
	position.x += (1 if is_facing_right else -1) * 15
	
	await get_tree().create_timer(0.2).timeout
	can_flip = true


func damage_player() -> void:
	if player:
		player.take_damage()


func position_sprites(animation : String) -> void:
	if ignore_positioning:
		return
	
	if animation.contains("attack"):
		if sprites.flip_h:
			sprites.position = SHIFTED_SPRITES_POSITION_RIGHT
		else:
			sprites.position = SHIFTED_SPRITES_POSITION_LEFT
	else:
		sprites.position = INITIAL_SPRITES_POSITION


func play_animation(animation : String, backwards : bool = false) -> void:
	if is_dead and animation != "dead":
		return
	
	if sprites.sprite_frames.get_animation_names().find(animation) == -1:
		return
	
	position_sprites(animation)
	
	if backwards:
		sprites.play_backwards(animation)
	else:
		sprites.play(animation)


func take_damage(_damage_amount: int = 1) -> void:
	if is_dead:
		return
	
	is_dead = true
	is_moving = false
	damaging_player = false
	player = null
	detected_player = null
	
	play_animation("dead")
	if dead_sfx:
		dead_sfx.play()


func _on_damage_area_body_entered(body: Node2D) -> void:
	player = body as Player


func _on_damage_area_body_exited(_body: Node2D) -> void:
	player = null


func _on_sprites_frame_changed() -> void:
	if not sprites:
		return
	if sprites.animation != "attack":
		damaging_player = false
	match sprites.animation:
		"transform":
			if sprites.frame == 3:
				transform_sfx.play(0.55)
		"alert":
			if sprites.frame == 9:
				alert_sfx.play()
		"attack":
			if sprites.frame == 0:
				spawn_sfx.play()
				is_moving = false
			if sprites.frame == 11:
				spawn_sfx.stop()
				attack_sfx.play(0.18)
			elif sprites.frame > damage_player_range.x and sprites.frame < damage_player_range.y:
				damage_player()
			elif sprites.frame == 19:
				spawn_sfx.play(1)


func _on_animated_sprite_2d_animation_finished() -> void:
	match sprites.animation:
		"dead":
			queue_free()
		"transform":
			if wants_to_return:
				wants_to_return = false
				play_animation("walk")
				is_moving = true
			elif not detected_player:
				play_animation("walk")
				is_moving = true
			else:
				play_animation("alert")
		"alert":
			play_animation("attack")
			damaging_player = true
			is_moving = false
		"attack":
			damaging_player = false
			if wants_to_return:
				wants_to_return = false
				play_animation("transform", true)
			else:
				await get_tree().create_timer(0.5).timeout
				play_animation("attack")
				damaging_player = true
				is_moving = false


func _on_detect_area_body_entered(body: Node2D) -> void:
	if is_dead:
		return
	detected_player = body as Player
	wants_to_return = false
	if sprites.animation == "walk" or sprites.animation == "transform":
		play_animation("transform")
		is_moving = false


func _on_detect_area_body_exited(_body: Node2D) -> void:
	if is_dead:
		return
	detected_player = null
	wants_to_return = true
