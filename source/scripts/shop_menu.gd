extends Control

onready var items = $items.get_children()


func update_shop_display():
	for index  in range( self.items.size() ):
		if index < Globals.shop.items.size():
			var item = Globals.shop.items[ index ]
			self.items[ index ].set_texture( item.texture )
			var can_buy = Globals.inventory.can_buy( item.price )
			self.items[ index ].set_can_buy( can_buy )
			self.items[ index ].visible = true
		else:
			self.items[ index ].visible = false


func _on_close_pressed():
	Event.emit_signal( "shop_close_pressed" )
