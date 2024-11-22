extends RigidBody2D

@onready var Fireblast: PackedScene = preload("res://scenes/fireblast.tscn")

func _on_body_entered(body: Node) -> void:
	# Ensure the fireball doesn't hit the player
	if !body.is_in_group("player"):
		do_damage(body)
		# Instantiate Fireblast and pass rotation
		var fireblast_instance = Fireblast.instantiate()
		fireblast_instance.position = get_global_position() 
		fireblast_instance.rotation = rotation  # Pass rotation to the new instance
		get_tree().get_root().add_child(fireblast_instance)
		queue_free()

func do_damage(body: Node2D):
	if not body:
		return
	if body.is_in_group("enemy"):
		# TODO Fireball shouldn't have to know the existence of Mage. 
		# Use Custom Signals to Alert Player Instead
		body.enemy_take_damage(preload("res://resources/Mage.tres").attack_damage)
	elif body.is_in_group("player"):
		body.player_take_damage(preload("res://resources/Mage.tres").attack_damage)
	
