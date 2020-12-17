extends Node2D

const SPEED = 3.0

var bottom_position = Vector2( 0.0, 0.0 )
var top_position = Vector2( 0.0, 300.0 )

var current = 0.0 

func _ready():
	Globals.main = self


func _process(delta): 
	if Globals.is_in_kitchen( Globals.player.position ):
		self.current = max( self.current - delta * SPEED, 0.0 )
	else: 
		self.current = min( self.current + delta * SPEED, 1.0 )
		
	self.position.y = lerp( bottom_position.y, top_position.y, self.current )


func has_point( point: Vector2 ) -> bool:
	var rect = Rect2(
		$drop_area.position - $drop_area.shape.extents,
		$drop_area.shape.extents * 2.0
	)
	
	return rect.has_point( point )
