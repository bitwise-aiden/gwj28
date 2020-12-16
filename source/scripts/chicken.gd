class_name chicken
extends KinematicBody2D

enum states { idle = 0, wandering, laying }
var animation_states = [ "idle", "wandering", "laying" ]

# wandering: have random offset and move in that direction 
	# occasionally change offset 
	# if colliding with walls, use bounce to move in different direction

# idle: play animation, on end of animation have small chance of dropping coin

# laying: randomly deciding to lay egg, spawning egg object


const CHANGE_DIRECTION_CHANCE = 100
const SPAWN_COIN_CHANCE = 1000
const SPAWN_EGG_CHANCE = 1000

var pickup_scene = load( "res://source/scenes/pickup.tscn" )
var coin_resource = load( "res://source/resources/pickups/pickup_coin.tres" )
var egg_resource = load( "res://source/resources/pickups/pickup_egg.tres" )

onready var main_instance = self.get_node( "/root/main" )
onready var sprite = $sprite

var state = states.idle

var direction: Vector2 = Vector2.UP
var speed: float = 50.0
var speed_modifier: float = 1.0

var time_elapsed = 0.0
var laying_cooldown = 0.0

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


func handle_laying( delta: float ) -> void:
	self.time_elapsed += delta * 50.0
	
	$sprite.position.y = sin( self.time_elapsed ) * 5.0

func handle_wandering( delta: float ) -> void:
	if self.speed_modifier != 1.0:
		self.speed_modifier = max( 1.0, self.speed_modifier - delta )
	else:
		self.laying_cooldown = max( 0.0, self.laying_cooldown - delta )
		
		if self.laying_cooldown == 0.0 && randi() % self.SPAWN_EGG_CHANCE == 0:
			self.laying_cooldown = 2.0
			self.set_state( states.laying )
			return
	
		if randi() % self.CHANGE_DIRECTION_CHANCE == 0: 
			self.direction = self.direction.rotated( randf() * PI - PI * 0.5 )
			self.set_state( states.idle )
			return
	
	self.time_elapsed += delta * 20.0 * self.speed_modifier
	$sprite.scale.y = 1.0 + sin( self.time_elapsed ) * 0.1
	
	var offset = self.direction * self.speed * self.speed_modifier * delta
	
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
			if randi() % self.SPAWN_COIN_CHANCE == 0:
				self.spawn( self.coin_resource, self.direction * 20.0)
		states.laying:
			self.set_state( states.wandering )
			self.spawn( self.egg_resource, Vector2(self.direction.x * -2.0, -3.0) )


func set_state( incoming_state ) -> void:
	self.state = incoming_state
	
	self.scale.y = 1.0
	self.time_elapsed = 0.0
	
	sprite.play( self.animation_states[ incoming_state ] )


func spawn( resource: Resource, offset: Vector2 ) -> void:
	var instance = self.pickup_scene.instance()
	
	instance.pickup_resource = resource
	instance.global_position = self.position + offset
	
	self.main_instance.call_deferred( "add_child", instance )


func _on_detector_body_entered(body):
	if body is Player:
		self.direction = (self.global_position - body.global_position).normalized()
		self.speed_modifier = 3.0
	elif self.speed_modifier > 1.0 && body.get_script() == self.get_script():
		body.direction = self.direction
		body.speed_modifier = self.speed_modifier
