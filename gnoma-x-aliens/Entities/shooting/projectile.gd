extends CharacterBody2D
class_name Projectile


signal hit(body : Node2D)
signal ended_lifetime(projectile : Projectile)


@export var is_from_player : bool:
	set = set_is_from_player
@export var enabled : bool:
	set = enable
@export var max_time_alive : float = 3.0


@onready var hit_area: Area2D = $HitArea
@onready var hit_area_collision_shape: CollisionShape2D = $HitArea/HitAreaCollisionShape
@onready var max_time_alive_timer: Timer = $MaxTimeAliveTimer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite


func _ready() -> void:
	is_from_player = is_from_player
	enabled = enabled
	animated_sprite.material = ShaderMaterial.new()
	(animated_sprite.material as ShaderMaterial).shader = load("uid://i8xl186i1o18")
	

func _physics_process(_delta: float) -> void:
	if not enabled:
		return
	move_and_slide()


func change_outline_color(color : Color) -> void:
	animated_sprite.material.set("shader_parameter/width",1)
	animated_sprite.material.set("shader_parameter/outline_color",color)
	pass


func set_is_from_player(value : bool) -> void:
	is_from_player = value
	if Util.collision_layer_values.is_empty():
		return
	if is_from_player:
		hit_area.collision_mask = Util.collision_layer_values["Enemy"]
	else:
		hit_area.collision_mask = Util.collision_layer_values["Player"]


func enable(value : bool) -> void:
	enabled = value
	if not hit_area:
		return
	
	if enabled:
		max_time_alive_timer.start(max_time_alive)
	else:
		max_time_alive_timer.stop()
	
	hit_area_collision_shape.set_deferred("disabled", not enabled)
	visible = enabled


func _on_hit_area_body_entered(body: Node2D) -> void:
	hit.emit(body)
	_on_end_lifetime()


func _on_end_lifetime() -> void:
	ended_lifetime.emit(self)
	enabled = false
