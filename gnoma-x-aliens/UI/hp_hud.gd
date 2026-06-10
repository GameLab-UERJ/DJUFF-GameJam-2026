# TODO: Leaderboard
# TODO: Conectar signals para detectar: mudança de vida e quantia de bolhas

extends CanvasLayer

var bubble_count: int = 0
var health_count: int = 3

@onready var player = $"../Player"
@onready var bubble_number = $"VBoxContainer/BubbleBar/BubbleNumber"
@onready var health_bar = $"VBoxContainer/HealthBar"

@onready var health: Array = health_bar.get_children()

func add_bubble() -> void:
	bubble_count += 1
	bubble_number.text = str(bubble_count)

func remove_bubble() -> void:
	if bubble_count <= 0:
		return
		
	bubble_count -= 1
	bubble_number.text = str(bubble_count) 

func health_change() -> void:
	health_count = clamp(health_count - 1, 0, 3)
	
	# iterar sobre a barra e alterar opacidade
	for i in range(health.size()):
		if i < health_count:
			health[i].modulate.a = 1.0
		else:
			health[i].modulate.a = 0.4
	
		
