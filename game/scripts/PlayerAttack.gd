extends State
class_name PlayerAttack

@export var sprite: AnimatedSprite2D

func Enter():
	sprite.play("Attack")
	pass
	
func Update(_delta: float): 
	if Input.get_vector("move_left", "move_right", "move_up", "move_down"):
		state_transition.emit(self, "PlayerMovement")
	if Input.is_action_just_pressed("spacebar"):
		state_transition.emit(self, "PlayerAttack")
	
func Exit():
	pass
	
