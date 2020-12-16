extends Sprite

const STAR_COUNT = 100


func _ready():
	for i in range( self. STAR_COUNT ):
		var star = Globals.SCENE_STAR.instance()
		star.position = Vector2(
			randi() % Globals.SCREEN_WIDTH, 
			randi() % Globals.SCREEN_HEIGHT
		)
		
		star.speed = randf() * Globals.STAR_MAX_SPEED
		
		self.call_deferred( "add_child", star )
