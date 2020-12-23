extends TextureButton


export ( int ) var inventory_index = 0
export ( Dictionary ) var omelette_item_textures = {}


onready var omelette_items = $omelette.get_children()

var has_item = false
var is_craftable = false


func _ready() -> void:
	self.add_to_group( "inventory_slot" )
	$key.play( str( self.inventory_index + 1 ) )


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
	
	self.has_item = true
	self.is_craftable = false
	
	$key.show_inventory_keys( true )


func set_texture( texture: Texture ) -> void:
	$item.texture = texture
	$item.visible = true
	$omelette.visible = false
	
	self.has_item = texture != null
	self.is_craftable = true
	
	$key.show_inventory_keys( true )


func set_quantity( quantity: int ) -> void:
	$quantity.visible = quantity > 1
	$quantity.text = "%d" % [ quantity ] 
