extends AnimatedSprite2D

func _on_animation_finished() -> void:
	print("Fireblast queue free")
	queue_free()
