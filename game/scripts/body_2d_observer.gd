extends Node

var debug_name = "BODY2D OBSERVER "
signal health_changed(entity, current_health, max_health)

# Dictionary to store entities and their health values
var observed_entities = []
var signals_to_observe = [SignalBus.health_changed]


func observe_entity(entity):
	if entity not in observed_entities:
		observed_entities.append(entity)
		
	if entity in observed_entities:
		Debug.log(debug_name + "entity already stored in observed entities!")
	
	for sig in signals_to_observe:
		sig.connect(_on_entity_health_changed)
	
	
func unobserve_entity(entity):
	
	if entity in observed_entities:
		for sig in signals_to_observe:
			sig.disconnect(_on_entity_health_changed)
		observed_entities.erase(entity)
		
	if entity not in observed_entities:
		Debug.log(debug_name + "entity not stored in observed entities!")


func _on_entity_health_changed(entity, current_health, max_health):
	$"..".entity_health_changed(entity, current_health, max_health)
