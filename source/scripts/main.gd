class_name Main
extends YSort


func _ready() -> void:
	randomize()
	

func _input( event ):
	var previous = Globals.input_type
	
	if event is InputEventMouseMotion || event is InputEventKey:
		Globals.input_type = "keyboard"
	
	if event is InputEventJoypadButton || event is InputEventJoypadMotion:
		Globals.input_type = "controller"
	
	if previous != Globals.input_type:
		Event.emit_signal( "input_type_changed" )


func _process( delta: float ) -> void:
	if Input.is_action_just_pressed( "debug" ) && false:
#		self.get_tree().reload_current_scene()

		for i in range( 10 ):
			Event.emit_signal( "pick_up_item", Globals.RESOURCE_EGG.duplicate() )
			
		for i in range( 10 ):
			Event.emit_signal( "pick_up_item", Globals.RESOURCE_BACON.duplicate() )

		for i in range( 10 ):
			Event.emit_signal( "pick_up_coin", Globals.RESOURCE_COIN.duplicate() )
			

		for i in range( 30 ):
			var dup = Globals.RESOURCE_OMELETTE.duplicate()
			dup.name = "Omelette\n - %d x Egg" % [ int( i / 10 ) + 1 ]
			dup.metadata[ "items" ] = {}
			dup.metadata[ "items" ][ "Egg" ] = int( i / 10 ) + 1

			Event.emit_signal( "pick_up_item", dup )
			

