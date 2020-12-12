class_name Pickup
extends Node2D


export ( Resource ) var pickup_resource = null


var speed_max = 500.0

var acceleration_time = 0.5
var time_elapsed = 0.0

var target = null


func _ready() -> void:
	if self.pickup_resource == null:
		self.call_deferred( "queue_free" )
		return

	self.position *= 1
	
	$sprite.texture = self.pickup_resource.texture
	$area/collision.shape.radius = self.pickup_resource.radius


func _process( delta: float ) -> void:
	if target:
		self.time_elapsed = min( 
			self.time_elapsed + delta, 
			self.acceleration_time 
		)
		
		var time = self.time_elapsed / self.acceleration_time
		var speed = lerp( 0, self.speed_max, 1 - pow( 1 - time, 2 ) )
		
		self.position = self.position.move_toward( 
			target.position, 
			speed * delta 
		)
		
		var distance = ( self.target.position - self.position ).length()
		if distance < 10.0:
			Event.emit_signal( 
				self.pickup_resource.method, 
				self.pickup_resource 
			)
			self.call_deferred( "queue_free" )


func _on_body_entered( body ):
	if body is Player:
		self.target = body
