extends Resource
class_name Mage

@export var character_name: String = "Mage"
@export var projectile_speed = 250
@export var current_health: int  = 100
@export var max_health: int = 100
@export var health_regen: float = 3
@export var health_regen_delay: float = 1
@export var speed: float = 150
@export var attack_damage: int = 60
@export var attack_rate: float = 0.75
@export var animations: Dictionary 

func _init():
	print("Initializing Mage")
	animations = {
		"Attack": "res://resources/animations/Mage_Attack.res",
		"Idle": "res://resources/animations/Mage_Idle.res",
		"Walk": "res://resources/animations/Mage_Walk.res"		
	}
	
func get_attack_data() -> Dictionary:
	var fireball = load("res://scenes/fireball.tscn")
	print("Got " + character_name + "attack data")	
	return {
		"attack_type": "projectile",
		"projectile_scene": fireball,
		"projectile_speed": projectile_speed
	}
	
func activate_sp_ability():
	pass
	
func activate_ultimate():
	pass
