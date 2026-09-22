extends Area2D

@export var speed: float = 600.0
var direction: Vector2 = Vector2.RIGHT

func _physics_process(delta: float) -> void:
	var direction_vector = Vector2.RIGHT.rotated(global_rotation)
	global_position += direction_vector * speed * delta

func _on_body_entered(body: Node) -> void:
	# Proteção total: Se colidir com o Player que atirou ou qualquer outro CharacterBody2D amigável, ignora
	if body.name == "Player" or (body is CharacterBody2D and not body.is_in_group("enemies")):
		return

	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(1)
		queue_free()
	
	elif body is TileMapLayer or body is StaticBody2D:
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
