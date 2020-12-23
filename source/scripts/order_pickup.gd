extends Node2D


onready var start_position = self.position
onready var on_screen_position = Vector2( 200.0, self.position.y )
var desired_move_speed = 100.0

var order = null
var target_area = null


func _ready():
	self.add_queue(
		Task.WaitForFunc.new(
			funcref( self, "wait_for_order" )
		)
	)


func add_queue( task: BaseTask ) -> void:
	TaskManager.add_queue( self.name, task )


func duration_to_location( start, end ) -> float:
	return (  start - end ).length() / self.desired_move_speed


func find_order_area() -> bool:
	if self.target_area:
		return true
	
	for order_area in self.get_tree().get_nodes_in_group( "order_pickup_area" ):
		if !order_area.has_order():
			order_area.set_order( self.order )
			
			self.target_area = order_area
			
			
			var target_location = self.target_area.position - Vector2( 150.0, 0.0 )
			var y_target = Vector2( self.position.x, target_location.y )
			
			self.add_queue(
				Task.RunFunc.new(
					funcref( $flames_left, "set_visible" ),
					[ false ]
				)
			)
			
			self.add_queue( 
				Task.Lerp.new( 
					PI * 0.5,
					0,
					0.5,
					funcref( self, "set_rotation" )
				)
			)
			
			self.add_queue(
				Task.RunFunc.new(
					funcref( $flames_left, "set_visible" ),
					[ true ]
				)
			)
			
			self.add_queue(
				Task.Lerp.new(
					self.position, 
					y_target, 
					self.duration_to_location( self.position, y_target ),
					funcref( self, "set_position" ) 
				)
			)
			
			self.add_queue(
				Task.RunFunc.new(
					funcref( $flames_right, "set_visible" ),
					[ false ]
				)
			)
			
			
			self.add_queue( 
				Task.Lerp.new( 
					0,
					PI * 0.5,
					0.5,
					funcref( self, "set_rotation" )
				)
			)
			
			self.add_queue(
				Task.RunFunc.new(
					funcref( $flames_right, "set_visible" ),
					[ true ]
				)
			)
			
			self.add_queue(
				Task.Lerp.new(
					y_target,
					target_location,
					self.duration_to_location( y_target, target_location ),
					funcref( self, "set_position" ) 
				)
			)
			
			self.add_queue(
				Task.RunFunc.new(
					funcref( self, "prepare_order_area" )
				)
			)
			
			self.add_queue(
				Task.RunFunc.new(
					funcref( $flames_right, "set_visible" ),
					[ false ]
				)
			)
			
			self.add_queue(
				Task.RunFunc.new(
					funcref( $flames_left, "set_visible" ),
					[ false ]
				)
			)
			
			self.add_queue(
				Task.RunFunc.new(
					funcref( self.order, "set_should_tick" ),
					[ true ]
				)
			)
			
			self.add_queue(
				Task.WaitForFunc.new(
					funcref( self, "wait_for_collection" )
				)
			)
			
			return true
	
	return false


func prepare_order_area() -> void:
	self.target_area.order_pickup_arrived = true


func set_position( position: Vector2 ) -> void:
	self.position = position


func wait_for_collection() -> bool:
	if Globals.tutorial_current_stage == 11 && Globals.advance_tutorial( 12 ):
		if Globals.player.focused_order_pickup_areas:
			Globals.advance_tutorial( 13 )
		else:
			Globals.indicator.position = self.target_area.position + Vector2( 50.0, 0.0 )
			Globals.indicator.rotation = PI * 0.5
			Globals.indicator.state = 2
			Globals.indicator.z_index = 2
			Globals.indicator.visible = true
	
	
	if !self.order.fulfilled:
		return false
	
	
	self.order = null
	self.target_area.set_order( null )
	self.target_area = null
	
	var x_target = Vector2( self.start_position.x, self.position.y )
	
	self.add_queue(
		Task.RunFunc.new(
			funcref( $flames_right, "set_visible" ),
			[ true ]
		)
	)
	
	self.add_queue( 
		Task.Lerp.new(
			PI * 0.5,
			-PI * 0.5,
			0.5,
			funcref( self, "set_rotation" )
		)
	)
			
	self.add_queue(
		Task.RunFunc.new(
			funcref( $flames_left, "set_visible" ),
			[ true ]
		)
	)
	
	self.add_queue(
		Task.Lerp.new(
			self.position, 
			x_target, 
			self.duration_to_location( self.position, x_target ),
			funcref( self, "set_position" ) 
		)
	)
	
	self.add_queue(
		Task.Lerp.new(
			x_target, 
			self.start_position, 
			self.duration_to_location( x_target, self.start_position ),
			funcref( self, "set_position" ) 
		)
	)
	
	self.add_queue(
		Task.WaitForFunc.new(
			funcref( self, "wait_for_order" )
		)
	)
	
	return true


func wait_for_order() -> bool:
	self.order = Globals.order_menu.get_order_for_pickup()
	if !self.order:
		return false
	
	self.order.order_pickup = self
	$color.modulate = self.order.color
	
	self.add_queue(
		Task.RunFunc.new(
			funcref( self, "set_rotation" ),
			[ PI * 0.5 ]
		)
	)
	
	self.add_queue(
		Task.Lerp.new( 
			self.position, 
			self.on_screen_position, 
			self.duration_to_location( self.position, self.on_screen_position ),
			funcref( self, "set_position" ) 
		)
	)
	
	self.add_queue(
		Task.WaitForFunc.new(
			funcref( self, "find_order_area" )
		)
	)
	
	return true
