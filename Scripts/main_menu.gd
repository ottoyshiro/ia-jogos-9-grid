extends CanvasLayer

func _on_button_pressed() -> void:
	self.get_tree().change_scene_to_packed(preload("res://Scenes/world.tscn"))
