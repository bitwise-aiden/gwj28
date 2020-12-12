class_name Main
extends YSort


func _ready() -> void:
	randomize()
	
	for i in range( 100 ):
		var instance = load( "res://source/scenes/pickup.tscn" ).instance()
		instance.position = Vector2(
			randi() % 2048 - 1024,
			randi() % 1200 - 600
		)
		
		if randi() % 2:
			instance.pickup_resource = load( "res://source/resources/pickups/pickup_coin.tres" )
		else:
			instance.pickup_resource = load( "res://source/resources/pickups/pickup_egg.tres" )
			
		
		self.call_deferred( "add_child", instance )


func _process( delta: float ) -> void:
	if Input.is_action_just_pressed( "debug" ):
		self.get_tree().reload_current_scene()
