extends CharacterBody2D
class_name Player


signal died
signal took_damage


var last_position : Vector2
var is_in_dialog : bool = false:
	set(value):
		is_in_dialog = value
		if movement_component:
			movement_component.enabled = not is_in_dialog
var _is_dead : bool = false


@onready var base_sprite: AnimatedSprite2D = $BaseSprite
@onready var movement_component: MovementComponent = $MovementComponent
@onready var footsteps_player: AudioStreamPlayer2D = $SfxPlayers/FootstepsPlayer
@onready var jump_player: AudioStreamPlayer2D = $SfxPlayers/JumpPlayer
@onready var land_player: AudioStreamPlayer2D = $SfxPlayers/LandPlayer


func just_died() -> void:
	if _is_dead:
		return
	_is_dead = true
	movement_component.enabled = false
	base_sprite.play("die")


func take_damage() -> void:
	took_damage.emit()


func _on_movement_component_changed_facing(left: bool) -> void:
	if left:
		base_sprite.flip_h = true
	else:
		base_sprite.flip_h = false


func _on_base_sprite_frame_changed() -> void:
	if not base_sprite:
		return 
	match base_sprite.animation:
		"walk":
			match base_sprite.frame:
				1,3:
					footsteps_player.play()


func _on_base_sprite_animation_finished() -> void:
	match base_sprite.animation:
		"die":
			collision_layer ^= Util.collision_layer_values["Player"]
			died.emit()


func _on_movement_state_machine_player_transited(from: Variant, to: Variant) -> void:
	match to:
		"Idle":
			if from == "GoingDown":
				land_player.play(0.08)
			base_sprite.play("idle")
		"Walking":
			base_sprite.play("walk")
		"GoingUp":
			base_sprite.play("jump")
			jump_player.play(0.3)
		"GoingDown":
			base_sprite.play("fall")


func _on_movement_state_machine_player_updated(state: Variant, _delta: Variant) -> void:
	match state:
		"Walking":
			if not base_sprite.is_playing():
				base_sprite.play("walk")
