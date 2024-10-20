extends RigidBody2D

@onready var Fireblast: PackedScene = preload("res://scenes/fireblast.tscn")

func _on_body_entered(body: Node) -> void:
	if !body.is_in_group("player"):
		var fireblast_instance = Fireblast.instantiate()
		fireblast_instance.position = get_global_position() 
		get_tree().get_root().add_child(fireblast_instance)
		queue_free()
