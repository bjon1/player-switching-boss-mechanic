extends RigidBody2D

@onready var Fireblast: PackedScene = preload("res://scenes/fireblast.tscn")

func _on_body_entered(body: Node) -> void:
	# TODO Fix sprite & logic so that the fireball never hits the player
	if !body.is_in_group("player"):
		do_damage(body)
		var fireblast_instance = Fireblast.instantiate()
		fireblast_instance.position = get_global_position() 
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
	
