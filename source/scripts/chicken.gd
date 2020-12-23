class_name chicken
extends KinematicBody2D

enum states { idle = 0, wandering, laying }
var animation_states = [ "idle", "wandering", "laying" ]

onready var sprite = $sprite

var state = states.idle

var direction: Vector2 = Vector2.UP
var speed_modifier: float = 1.0

var time_elapsed = 0.0
var laying_cooldown = 0.0

#
func _ready() -> void:
	self.set_state( states.idle )
	self.time_elapsed = randf() * TAU
	self.direction = self.direction.rotated( randf() * TAU )


func _process( delta: float ) -> void:
	match self.state:
		states.wandering:
			self.handle_wandering( delta )
		states.laying:
			self.handle_laying( delta )
			
	if randi() % 500 == 0:
		$cluck.play( 3.0 )


func handle_laying( delta: float ) -> void:
	self.time_elapsed += delta * 50.0
	
	$sprite.position.y = sin( self.time_elapsed ) * 5.0


func handle_wandering( delta: float ) -> void:
	if self.speed_modifier != 1.0:
		self.speed_modifier = max( 1.0, self.speed_modifier - delta )
	else:
		self.laying_cooldown = max( 0.0, self.laying_cooldown - delta )
		
		if self.should_lay_egg():
			self.laying_cooldown = 2.0
			$lay.play()
			self.set_state( states.laying )
			return
	
		if randi() % Globals.CHICKEN_CHANGE_DIRECTION_CHANCE == 0: 
			self.direction = self.direction.rotated( randf() * PI - PI * 0.5 )
			self.set_state( states.idle )
			return
	
	self.time_elapsed += delta * 20.0 * self.speed_modifier
	$sprite.scale.y = 1.0 + sin( self.time_elapsed ) * 0.1
	
	var offset = (
		self.direction * 
		Globals.CHICKEN_SPEED * 
		self.speed_modifier * 
		delta
	)
	
	if offset.x <= 0:
		$sprite.scale.x = -1
	else:
		$sprite.scale.x = 1
	
	var collision = self.move_and_collide( offset )
	
	if !collision:
		return
	
	self.direction = self.direction.bounce( collision.normal )
	
	if collision.collider is Player:
		self.speed_modifier = 2.0
	else:
		if randi() % 3 == 0: 
			self.set_state( states.idle )


func _on_animation_finished():
	match state:
		states.idle:
			self.set_state( states.wandering )
		states.laying:
			self.set_state( states.wandering )
			
			var offset = Vector2( self.direction.x * -2.0, -3.0 )
			var position = self.position + offset
			Globals.spawn_pickup( Globals.RESOURCE_EGG, position)
			Globals.first_egg = true


func should_lay_egg():
	if Globals.tutorial_current_stage == 2:
		Globals.advance_tutorial( 3 )
		return true
	
	# TODO: Prevent chicken spawning eggs while working on shop
	
	return (
		!Globals.is_in_kitchen( self.position ) && 
		self.laying_cooldown == 0.0 && 
		randi() % Globals.CHICKEN_SPAWN_EGG_CHANCE == 0 && 
		Globals.tutorial_current_stage >= 14
	)

func set_state( incoming_state ) -> void:
	self.state = incoming_state
	
	self.scale.y = 1.0
	self.time_elapsed = 0.0
	
	sprite.play( self.animation_states[ incoming_state ] )


func _on_detector_body_entered(body):
	if body is Player:
		self.direction = (self.position - body.position).normalized()
		self.speed_modifier = Globals.CHICKEN_SPEED_MODIFER_MAX
	elif self.speed_modifier > 1.0 && body.get_script() == self.get_script():
		body.direction = self.direction
		body.speed_modifier = self.speed_modifier
