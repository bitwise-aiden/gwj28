class_name Main
extends YSort


func _ready() -> void:
	randomize()


func _process( delta: float ) -> void:
	if Input.is_action_just_pressed( "debug" ):
		self.get_tree().reload_current_scene()
