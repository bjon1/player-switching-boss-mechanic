extends Node2D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	var body2d_entities = get_tree().get_nodes_in_group("body2d")
	for entity in body2d_entities:
		$Body2DObserver.observe_entity(entity)
		Debug.log("Add Observe Entity")
		

func entity_health_changed(entity, current_health, max_health) -> void:
	Debug.log("ROOT Health Changed")
	
	var health_bar = entity.get_node("HealthBar") 
		
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health
	else:
		Debug.log("Error: HealthBar node not found under the entity!")
