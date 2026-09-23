extends CanvasLayer

@export var player : CharacterBody2D

@onready var health_label: Label = %HealthLabel
@onready var ammo_label: Label = %AmmoLabel

func _ready() -> void:
	health_label.text = "HEALTH: " + str(player.health) + "/" + str(player.MAX_HEALTH)
	ammo_label.text = "AMMO: " + str(player.ammo) + "/" + str(player.MAX_AMMO)


func update():
	health_label.text = "HEALTH: " + str(player.health) + "/" + str(player.MAX_HEALTH)
	ammo_label.text = "AMMO: " + str(player.ammo) + "/" + str(player.MAX_AMMO)
