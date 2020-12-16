class_name Main
extends YSort


func _ready() -> void:
	randomize()


#func _process( delta: float ) -> void:
#	if Input.is_action_just_pressed( "debug" ):
##		self.get_tree().reload_current_scene()
#
#		var omelette = load( "res://source/resources/pickups/pickup_omelette.tres" )
#		for i in range( 30 ):
#			var dup = omelette.duplicate()
#			dup.name = "Omelette\n - %d x Egg" % [ int( i / 10 ) + 1 ]
#			dup.metadata[ "items" ] = {}
#			dup.metadata[ "items" ][ "Egg" ] = int( i / 10 ) + 1
#
#			Event.emit_signal("pick_up_item", dup)
