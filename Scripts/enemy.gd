extends CharacterBody2D

@export var speed: float = 100.0
@export var stop_distance: float = 40.0
@export var player : CharacterBody2D
@export var health : int = 10
@export var attack_cooldown: float = 0.2 

var player_in_range: Node2D = null
var can_attack: bool = true

func _ready() -> void:
	pass # Replace with function body.


func _physics_process(_delta: float) -> void:
	if not player:
		return

	var direction = player.global_position - global_position
	
	var distance = direction.length()

	if distance > stop_distance:
		velocity = direction.normalized() * speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()
	
	if player_in_range and can_attack:
		attack_player()

func attack_player():
	if player_in_range.has_method("take_damage"):
		player_in_range.take_damage(1, global_position)
		print("Inimigo causou 1 de dano no Player!")
		
		# Inicia o tempo de recarga para não dar dano infinito
		can_attack = false
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true

func take_damage(damage : int):
	if health <= 0:
		queue_free()
	health -= damage

func _on_hitbox_body_entered(body: Node) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		player_in_range = body
		player.can_move = false

func _on_hitbox_body_exited(body: Node) -> void:
	if body == player_in_range:
		player_in_range = null
		player.can_move = true
