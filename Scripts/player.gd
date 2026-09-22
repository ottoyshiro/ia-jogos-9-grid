extends CharacterBody2D

const SPEED = 400.0

const WORLD_WIDTH = 2400
const WORLD_HEIGHT = 1800
const PLAYER_SIZE = 40
const PROJECTILE_SCENE = preload("res://Scenes/projectile.tscn")
const MAX_HEALTH = 10
const MAX_AMMO = 20

var can_shoot: bool = true
var health: int = 10
var knockback_velocity: Vector2 = Vector2.ZERO
var can_move: bool = true
var ammo: int = 20

@onready var ray_cast_2d: RayCast2D = %RayCast2D
@onready var ray_cast_2d_2: RayCast2D = %RayCast2D2
@onready var ray_cast_2d_3: RayCast2D = %RayCast2D3
@onready var ray_casts_pivot: Node2D = %RayCastsPivot
@onready var projectile_ref: Marker2D = %ProjectileRef

@onready var ray_casts : Array[RayCast2D] = [ray_cast_2d, ray_cast_2d_2, ray_cast_2d_3]

func _process(_delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if can_shoot:
			can_shoot = false
			shoot()
	else:
		can_shoot = true


func _physics_process(delta):
	var direction = Vector2.ZERO
	if can_move:
		if Input.is_key_pressed(KEY_W):
			direction.y -= 1

		if Input.is_key_pressed(KEY_S):
			direction.y += 1

		if Input.is_key_pressed(KEY_A):
			direction.x -= 1

		if Input.is_key_pressed(KEY_D):
			direction.x += 1

		if direction.length() > 0:
			direction = direction.normalized()
			ray_casts_pivot.global_rotation = direction.angle()

		velocity = direction * SPEED

	if knockback_velocity.length() > 100:
		# O movimento dele cai drasticamente para a força do impacto empurrá-lo
		velocity = direction * (SPEED * 0.2) + knockback_velocity
	else:
		# Movimento normal quando não está sob forte impacto
		velocity = direction * SPEED + knockback_velocity

	# Reduz o knockback gradualmente a cada frame
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 2000 * delta)
	
	if global_position.x <= 0.0 and velocity.x < 0:
		velocity.x = 0
	elif global_position.x >= (WORLD_WIDTH - PLAYER_SIZE) and velocity.x > 0:
		velocity.x = 0
		
	if global_position.y <= 0.0 and velocity.y < 0:
		velocity.y = 0
	elif global_position.y >= (WORLD_HEIGHT - PLAYER_SIZE) and velocity.y > 0:
		velocity.y = 0

	move_and_slide()
	colliding_with()
	
	position.x = clamp(position.x, 0.0, WORLD_WIDTH - PLAYER_SIZE)
	position.y = clamp(position.y, 0.0, WORLD_HEIGHT - PLAYER_SIZE)

func colliding_with():
	for ray_cast : RayCast2D in ray_casts:
		if !ray_cast.is_colliding():
			continue
		
		var obj = ray_cast.get_collider()
		
		if obj != null:
			if obj.is_in_group('ammos'):
				reload()
				obj.get_parent().queue_free()
			if obj.is_in_group('supplies'):
				heal()
				obj.get_parent().queue_free()

func reload():
	if ammo < MAX_AMMO:
		ammo = 20
		print('coletou municao')

func heal():
	if health < MAX_HEALTH:
		health += 1
		print('coletou suprimento')

func shoot():
	if ammo > 0:
		var projectile = PROJECTILE_SCENE.instantiate()
		
		# 1. Spawna na posição real do mundo
		projectile.global_position = global_position
		
		# 2. Calcula o ângulo real absoluto do Player até o Mouse no mundo
		var angle_to_mouse = global_position.angle_to_point(get_global_mouse_position())
		
		# 3. Aplica diretamente na ROTAÇÃO GLOBAL do projétil
		projectile.global_rotation = angle_to_mouse
		projectile.global_position = projectile_ref.global_position

		# 4. Adiciona direto na raiz do mapa
		get_tree().current_scene.add_child(projectile)
		ammo -= 1
	else:
		print("sem municao")

func take_damage(damage : int, enemy_position : Vector2):
	if health <= 0:
		print("morreu")
	health -= damage
	print("tomou")
	
	var knockback_direction = (global_position - enemy_position).normalized()
	knockback_velocity = knockback_direction * 650.0
	
	print("Player levou dano e foi empurrado!")
