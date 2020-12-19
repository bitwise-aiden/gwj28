extends Sprite


enum states { default, flashing, bouncing }
export var state = states.default


var time_elapsed = 0.0

func _ready() -> void:
	Globals.indicator = self


func _process( delta: float ) -> void:
	match self.state:
		states.flashing:
			self.time_elapsed += 10.0 * delta 
			self.visible = sin( self.time_elapsed ) > 0.0
		
		states.bouncing: 
			self.time_elapsed += 400.0 * (delta * delta)
			self.position.y += sin( self.time_elapsed ) * 0.1
