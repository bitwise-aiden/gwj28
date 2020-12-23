extends Node2D


var should_spawn = false

var top_left = Globals.CHICKEN_SPAWN_TOP_LEFT
var bottom_right = Globals.CHICKEN_SPAWN_BOTTOM_RIGHT

onready var shadow_position = $shadow.rect_position
onready var shadow_size = $shadow.rect_size.x
onready var oscillation_time_elapsed = 0.0

func _ready() -> void:
	self.visible = randi() % 100 == 0
	
	self.position = Vector2( 
		lerp( top_left.x, bottom_right.x, randf() ),
		lerp( top_left.y, bottom_right.y, randf() )
	)


func _process( delta: float ) -> void:
	if self.visible && randi() % 1000 == 0:
		$sprite.play( "blink" )
		self.should_spawn = Globals.tutorial_current_stage > 14\
	
	
	if $sprite.animation == "idle" && self.visible: 
		self.oscillation_time_elapsed += delta
		var offset = sin( -self.oscillation_time_elapsed ) * 0.5 + 0.5
		
		$shadow.rect_size.x = self.shadow_size - offset * 6.0
		$shadow.rect_position.x =  -self.shadow_size * 0.5 + offset * 3.0


func _on_sprite_animation_finished():
	$sprite.play( "idle" )
	self.oscillation_time_elapsed = 0.0
	
	if self.should_spawn && randi() % 10 == 0:
		Globals.spawn_pickup( 
			Globals.RESOURCE_COIN, 
			self.position + Vector2( 30.0, 30.0 )
		)
	
	self.should_spawn = false
