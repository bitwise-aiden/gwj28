extends Sprite


var speed
onready var time_elapsed = int( self.position.x )

func _ready(): 
	var ratio = self.speed / Globals.STAR_MAX_SPEED - 0.3
	self.scale = Vector2( ratio, ratio )

func _process( delta ):
	self.time_elapsed += delta * self. speed
	
	self.position.x = self.time_elapsed
	if self.position.x > Globals.SCREEN_WIDTH:
		self.position.x -= Globals.SCREEN_WIDTH
