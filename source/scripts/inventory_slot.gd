extends Control


export ( int ) var inventory_index = 0


func set_texture( texture: Texture ) -> void:
	$item.texture = texture


func set_quantity( quantity: int ) -> void:
	$quantity.visible = quantity > 1
	$quantity.text = "%d" % [ quantity ] 


func _on_pressed():
	Event.emit_signal( "inventory_slot_selected", self.inventory_index )


func _on_enter():
	print('Hello world', self.inventory_index)
	Event.emit_signal( "inventory_slot_entered", self.inventory_index )


func _on_exit():
	Event.emit_signal( "inventory_slot_exited", self.inventory_index )
