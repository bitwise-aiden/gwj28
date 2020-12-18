extends TextureButton


export ( int ) var inventory_index = 0
export ( Dictionary ) var omelette_item_textures = {}


onready var omelette_items = $omelette.get_children()


func _ready() -> void:
	self.add_to_group( "inventory_slot" )


func has_point( point: Vector2 ):
	var rect = Rect2(self.rect_global_position, self.rect_size)
	return rect.has_point( point )


func set_omelette( items ) -> void:
	$item.visible = false
	$omelette.visible = true
	
	for index in range( self.omelette_items.size() ):
		if index < items.size():
			var texture = self.omelette_item_textures[ items[ index ] ]
			self.omelette_items[ index ].texture = texture
			self.omelette_items[ index ].visible = true
		else:
			self.omelette_items[ index ].visible = false


func set_texture( texture: Texture ) -> void:
	$item.texture = texture
	$item.visible = true
	$omelette.visible = false


func set_quantity( quantity: int ) -> void:
	$quantity.visible = quantity > 1
	$quantity.text = "%d" % [ quantity ] 
