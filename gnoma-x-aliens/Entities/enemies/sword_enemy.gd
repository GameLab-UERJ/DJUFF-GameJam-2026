extends Enemy
class_name SwordEnemy


const INITIAL_SPRITES_POSITION : Vector2 = Vector2(0,-4)
const SHIFTED_SPRITES_POSITION_LEFT : Vector2 = Vector2(-20,-36)
const SHIFTED_SPRITES_POSITION_RIGHT: Vector2 = Vector2(20,-36)


var detected_player : Player
var player : Player
var damaging_player : bool


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

@onready var sprites: AnimatedSprite2D = $Sprites
@onready var damage_collision_shape: CollisionShape2D = $DamageArea/DamageCollisionShape


func _ready() -> void:
	is_facing_right = is_facing_right


func _physics_process(delta: float) -> void:
	update_facing()


func update_facing() -> void:
	if damaging_player:
		return
	if detected_player:
		if global_position.direction_to(detected_player.global_position).x < 0:
			is_facing_right = false
		else:
			is_facing_right = true


func damage_player() -> void:
	damaging_player = true
	#TODO
	if player:
		print('damaged player')


func position_sprites(animation : String) -> void:
	if animation.contains("attack"):
		if sprites.flip_h:
			sprites.position = SHIFTED_SPRITES_POSITION_RIGHT
		else:
			sprites.position = SHIFTED_SPRITES_POSITION_LEFT
	else:
		sprites.position = INITIAL_SPRITES_POSITION


func play_animation(animation : String, backwards : bool = false) -> void:
	if sprites.sprite_frames.get_animation_names().find(animation) == -1:
		return
	
	position_sprites(animation)
	
	if backwards:
		sprites.play_backwards(animation)
	else:
		sprites.play(animation)


func _on_damage_area_body_entered(body: Node2D) -> void:
	player = body as Player


func _on_damage_area_body_exited(body: Node2D) -> void:
	player = null


func _on_sprites_frame_changed() -> void:
	if not sprites:
		return
	match sprites.animation:
		"attack":
			if sprites.frame > 11 and sprites.frame < 16:
				damage_player()


func _on_animated_sprite_2d_animation_finished() -> void:
	match sprites.animation:
		"transform":
			if not detected_player:
				play_animation("idle")
			else:
				play_animation("alert")
		"alert":
			play_animation("attack")
			damaging_player = true
		"attack":
			damaging_player = false
			await get_tree().create_timer(0.5).timeout
			play_animation("attack")
			damaging_player = true


func _on_detect_area_body_entered(body: Node2D) -> void:
	detected_player = body as Player
	if sprites.animation == "idle" or sprites.animation == "transform":
		play_animation("transform")


func _on_detect_area_body_exited(body: Node2D) -> void:
	detected_player = null
	play_animation("transform",true)
