extends Control

onready var items = self.get_children()


func update_shop_display():
	for index  in range( self.items.size() ):
		if index < Globals.shop.items.size():
			var item = Globals.shop.items[ index ]
			self.items[ index ].set_texture( item.texture )
			var can_buy = (
				Globals.inventory.can_buy( item.price ) &&  
				abs( item.stock ) > 0 && 
				Globals.tutorial_current_stage > 14
			)
			
			if Globals.tutorial_current_stage == 16:
				can_buy = item.name == Globals.tutorial_extra_ingredient
			
			self.items[ index ].set_can_buy( can_buy )
			self.items[ index ].visible = true
		else:
			self.items[ index ].visible = false


func _on_close_pressed():
	Event.emit_signal( "shop_close_pressed" )


func update_controller_ui( index ):
	for i in range( self.items.size() ):
		if index == i: 
			self.items[ i ].modulate = Color.white
		else:
			self.items[ i ].modulate = Color("b0b0b0")
