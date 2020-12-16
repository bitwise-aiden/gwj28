extends TextureButton


export ( int ) var inventory_index = 0


func _ready() -> void:
	self.add_to_group( "inventory_slot" )
		


func has_point( point: Vector2 ):
	var rect = Rect2(self.rect_global_position, self.rect_size)
	return rect.has_point( point )


func set_texture( texture: Texture ) -> void:
	$item.texture = texture


func set_quantity( quantity: int ) -> void:
	$quantity.visible = quantity > 1
	$quantity.text = "%d" % [ quantity ] 
