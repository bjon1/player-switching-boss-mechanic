extends State
class_name PlayerMovement

@export var sprite: AnimatedSprite2D

func Enter():
	sprite.play("Walk")
	pass
	
func Update(_delta: float): 
	if Input.is_action_just_pressed("spacebar"):
		state_transition.emit(self, "PlayerAttack")
		
func Exit():
	sprite.stop()
	
