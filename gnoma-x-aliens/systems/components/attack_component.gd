extends Component
class_name AttackComponent


@export var gun : Gun
@export var left_point : Node2D
@export var right_point : Node2D
@export var shooting_cooldown_time : float = 1


@onready var cooldown: Timer = $Cooldown


func _ready() -> void:
	if not gun:
		push_error("AttackComponent must have Gun")


func _physics_process(_delta: float) -> void:
	if not cooldown.is_stopped():
		return
	
	if parent is Player and not parent._is_dead:
		if Input.is_action_pressed("shoot"):
			var direction : Vector2
			if parent.base_sprite.flip_h:
				gun.global_position = left_point.global_position
				direction = Vector2.LEFT
			else:
				gun.global_position = right_point.global_position
				direction = Vector2.RIGHT
			gun.shoot_to(direction)
			parent.base_sprite.play("shoot")
			cooldown.start(shooting_cooldown_time)
	
	if parent is Enemy and parent.detected_player:
		gun.global_position = right_point.global_position
		if parent.sprites.flip_h:
			gun.global_position = left_point.global_position
		gun.shoot_at(parent.detected_player)
		cooldown.start(shooting_cooldown_time)
		parent.play_animation("attack")
	
