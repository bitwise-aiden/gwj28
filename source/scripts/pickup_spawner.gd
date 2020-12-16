extends Node

onready var main_instance = self.get_node( "/root/main" )
onready var pickup_scene = load( "res://source/scenes/pickup.tscn" )

func spawn( resource: Resource, position: Vector2, is_dropped: bool = false):
	var instance = self.pickup_scene.instance()
	
	instance.position = position
	instance.pickup_resource = resource
	if is_dropped:
		instance.drop_cooldown = 1.0
	
	self.main_instance.call_deferred( "add_child", instance )
