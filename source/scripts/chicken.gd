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

func _ready() -> void:
	self.set_state( states.idle )


func _physics_process( delta: float ) -> void:
	if self.state != states.wandering:
		return
	
	if randi() % self.CHANGE_DIRECTION_CHANCE == 0: 
		self.direction = self.direction.rotated( randf() * PI - PI * 0.5 )
		self.set_state( states.idle )
		return
		
	if randi() % self.SPAWN_EGG_CHANCE == 0:
		self.set_state( states.laying )
		return
	
	var offset = self.direction * self.speed * delta
	
	var collision = self.move_and_collide( offset )
	
	if !collision:
		return
	
	self.direction = self.direction.bounce( collision.normal )
	
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
			self.spawn( self.egg_resource, self.direction * -20.0)


func set_state( incoming_state ) -> void:
	self.state = incoming_state
	
	sprite.play( self.animation_states[ incoming_state ] )


func spawn( resource: Resource, offset: Vector2 ) -> void:
	var instance = self.pickup_scene.instance()
	
	instance.pickup_resource = resource
	instance.global_position = self.position + offset
	
	self.main_instance.call_deferred( "add_child", instance )
