extends Control

onready var item_frames = $item_frames.get_children()

var focused_crafting_area = null


func has_point( point: Vector2 ) -> bool:
	var rect = Rect2($pan.rect_global_position, $pan.rect_size)
	return rect.has_point( point )


func update_ui( items ):
	for i in range( self.item_frames.size() ):
		if i < items.size():
			self.item_frames[ i ].texture = items[ i ].texture
		else:
			self.item_frames[ i ].texture = null


func _on_start_pressed():
	self.focused_crafting_area.start_cooking()


func _on_close_pressed():
	Event.emit_signal( "crafting_close_pressed" )
