extends Sprite


func _ready() -> void:
	self.add_to_group( "pickup_lerper" )


func lerp_texture( texture: Texture, from: Vector2, to: Vector2,
		duration: float ) -> void:
	
	self.texture = texture
	self.visible = true
	
	TaskManager.add_queue(
		self.name,
		Task.Lerp.new( 
			from,
			to,
			duration,
			funcref( self, "set_position" )
		)
	)
	
	TaskManager.add_queue(
		self.name,
		Task.RunFunc.new(
			funcref( self, "set_visible" ),
			[ false ]
		)
	)
	
	TaskManager.add_queue(
		self.name,
		Task.RunFunc.new(
			funcref( self, "set_position" ),
			[ Vector2( -1000.0, 0.0 ) ]
		)
	)
