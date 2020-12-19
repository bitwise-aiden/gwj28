extends Node2D

const SPEED = 3.0

var bottom_position = Vector2( 0.0, 0.0 )
var top_position = Vector2( 0.0, 325.0 )

var current = 0.0 

func _ready():
	Globals.main = self


func _process(delta): 
	if Globals.is_in_kitchen( Globals.player.position ):
		self.current = max( self.current - delta * SPEED, 0.0 )
		
		if Globals.tutorial_current_stage == 5:
			Globals.advance_tutorial( 6 )
			
	else: 
		self.current = min( self.current + delta * SPEED, 1.0 )
		
		if Globals.tutorial_current_stage == 1:
			Globals.advance_tutorial( 2 )
		
	self.position.y = lerp( bottom_position.y, top_position.y, self.current )

