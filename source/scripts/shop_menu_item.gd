extends Control

export ( int ) var index = 0 

func _ready() -> void:
	$key.play( str( self.index + 1 ) )


func set_texture( texture: Texture ) -> void:
	$item.texture = texture


func set_can_buy( can_buy: bool ) -> void:
	$key.visible = can_buy
	$item.self_modulate = "ffffff" if can_buy else "747474"
	$inventory_slot.self_modulate = "ffffff" if can_buy else "747474"


func _on_buy_button_pressed():
	Event.emit_signal( "shop_buy_pressed", index )
