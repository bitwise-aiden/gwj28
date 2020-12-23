extends Node2D


func _ready() -> void:
	Event.connect( "tutorial_advanced", self, "tutorial_advanced" )


func tutorial_advanced( stage ): 
	self.visible = stage <= 3
