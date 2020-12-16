class_name Pickup
extends Node2D


export ( Resource ) var pickup_resource = null


var speed_max = 500.0

var acceleration_time = 0.5
var time_elapsed = 0.0

onready var oscillation_time_elapsed = randf() * PI

var target = null

onready var shadow_size = $shadow.rect_size.x

var drop_cooldown = 0.0

func _ready() -> void:
	if self.pickup_resource == null:
		self.call_deferred( "queue_free" )
		return

	self.position *= 1
	
	$sprite.texture = self.pickup_resource.texture
	$area/collision.shape.radius = self.pickup_resource.radius


func _process( delta: float ) -> void:
	if self.drop_cooldown > 0.0:
		self.drop_cooldown = max( 0.0, self.drop_cooldown - delta )
	
	if (
		self.drop_cooldown == 0.0 && 
		self.target && 
		self.target.can_pickup( self.pickup_resource )
	):
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
	else:
		self.oscillation_time_elapsed += delta * 5.0
		$sprite.position.y = sin( self.oscillation_time_elapsed ) * 2.0
		
		var offset = sin( -self.oscillation_time_elapsed ) * 0.5 + 0.5
		
		$shadow.rect_size.x = self.shadow_size - offset * 6.0
		$shadow.rect_position.x = -self.shadow_size * 0.5 + offset * 3.0


func _on_body_entered( body ):
	if body is Player:
		self.target = body


func _on_body_exited(body):
	if body == self.target:
		self.target = null
