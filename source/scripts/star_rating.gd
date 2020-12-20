extends AnimatedSprite


export (int) var index


func _ready(): 
	Event.connect( "popularity_changed", self, "update_popularity" )


func update_popularity( amount: float ) -> void:
	if amount < index: 
		self.play( "0" )
	elif amount < index + 0.5: 
		self.play( "1" )
	else: 
		self.play( "2" )
