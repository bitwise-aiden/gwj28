class_name Main
extends YSort


func _ready() -> void:
	randomize()
	
	for i in range( 100 ):
		var instance = load( "res://source/scenes/pickup.tscn" ).instance()
		instance.position = Vector2(
			randi() % 1024,
			randi() % 600
		)
		
		instance.pickup_resource = load( "res://source/resources/pickups/pickup_coin.tres" )
		
		self.call_deferred( "add_child", instance )


func _process( delta: float ) -> void:
	if Input.is_action_just_pressed( "debug" ):
		self.get_tree().reload_current_scene()
