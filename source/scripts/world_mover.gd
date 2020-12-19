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
	else: 
		self.current = min( self.current + delta * SPEED, 1.0 )
		
	self.position.y = lerp( bottom_position.y, top_position.y, self.current )

