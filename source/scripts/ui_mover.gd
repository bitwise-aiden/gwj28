extends Node2D

const SPEED = 5.0

var bottom_position = Vector2( 0.0, 0.0 )
var top_position = Vector2( 0.0, -300.0 )

var current = 0.0 


func _process(delta): 
	if Globals.is_in_kitchen( Globals.player.global_position ):
		self.current = max( self.current - delta * SPEED, 0.0 )
	else: 
		self.current = min( self.current + delta * SPEED, 1.0 )
		
	self.position = lerp( bottom_position, top_position, self.current )
