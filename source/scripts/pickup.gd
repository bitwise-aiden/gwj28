class_name Pickup
extends Node2D


export ( Resource ) var pickup_resource = null

onready var oscillation_time_elapsed = randf() * PI
onready var shadow_size = $shadow.rect_size.x

var drop_cooldown = 0.0
var target = null
var time_elapsed = 0.0


func _ready() -> void:
	if self.pickup_resource == null:
		self.call_deferred( "queue_free" )
		return

	self.position *= 1
	
	$sprite.texture = self.pickup_resource.texture
	$area/collision.shape.radius = self.pickup_resource.radius
	
	var advance_4 = (
		Globals.tutorial_current_stage == 3 && Globals.advance_tutorial( 4 )
	)
	
	var advance_8 = (
		self.pickup_resource.orderable && 
		Globals.tutorial_current_stage == 9 && 
		Globals.advance_tutorial( 10 )
	)
	if  advance_4 || advance_8:
		Globals.indicator.position = self.position + Vector2( 0.0, -70.0 )
		Globals.indicator.rotation = 0
		Globals.indicator.state = 2
		Globals.indicator.z_index = 15
		Globals.indicator.visible = true


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
			Globals.PICKUP_ACCELERATION_TIME 
		)
		
		var time = self.time_elapsed / Globals.PICKUP_ACCELERATION_TIME
		var speed = lerp( 0, Globals.PICKUP_MAX_SPEED, 1 - pow( 1 - time, 2 ) )
		
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
		
		if Globals.tutorial_current_stage == 4:
			Globals.advance_tutorial( 5 )
		
		if Globals.tutorial_current_stage == 10:
			Globals.advance_tutorial( 11 )


func _on_body_exited(body):
	if body == self.target:
		self.target = null
