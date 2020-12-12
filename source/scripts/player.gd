class_name Player
extends KinematicBody2D


var speed: float = 300.0


func _process( delta: float ) -> void:
	var direction = Vector2(
		Input.get_action_strength( "right" ) -
		Input.get_action_strength( "left" ),
		Input.get_action_strength( "down" ) -
		Input.get_action_strength( "up" )
	).normalized()
	
	self.move_and_collide( direction * self.speed * delta ) 
