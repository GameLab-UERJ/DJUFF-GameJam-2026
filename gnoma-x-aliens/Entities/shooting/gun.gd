extends Node2D
class_name Gun


@export var projectile_scene : PackedScene
@export var gun_is_from_player : bool = true
@export_group("Projectile","projectile_")
@export var projectile_speed : float = 200
@export var projectile_scale : Vector2 = Vector2.ONE*2
@export var projectile_outline_color : Color = Color.BLACK


var _projectile_pool : Array[Projectile] = []
var _available_projectiles: Array[int]   = []


@onready var shoot_sfx: AudioStreamPlayer2D = $ShootSfx


func _ready() -> void:
	var bullets : Node2D = get_tree().current_scene.get_node_or_null("Projectiles")
	if not bullets:
		bullets = Node2D.new()
		bullets.name = "Projectiles"
		get_tree().current_scene.add_child.call_deferred(bullets)


func spawn_projectile() -> Projectile:
	if _available_projectiles.is_empty():
		_projectile_pool.append(projectile_scene.instantiate())
		_available_projectiles.append(len(_projectile_pool)-1)
		_projectile_pool[-1].ended_lifetime.connect(_on_ended_lifetime)
		_projectile_pool[-1].hit.connect(_on_hit_body)
		get_tree().current_scene.get_node("Projectiles").add_child(_projectile_pool[-1])
	
	return  _projectile_pool[_available_projectiles.pop_back()]


func shoot_to(direction : Vector2) -> void:
	var projectile : Projectile = spawn_projectile()
	projectile.global_position = global_position
	projectile.velocity = direction * projectile_speed
	projectile.scale = projectile_scale
	projectile.is_from_player = gun_is_from_player
	projectile.enabled = true
	projectile.change_outline_color(projectile_outline_color)
	shoot_sfx.play()


func shoot_at(node : Node2D) -> void:
	shoot_to(global_position.direction_to(node.global_position))


func _on_ended_lifetime(projectile : Projectile) -> void:
	_available_projectiles.append(_projectile_pool.find(projectile))


func _on_hit_body(body : Node2D) -> void:
	body.take_damage()
