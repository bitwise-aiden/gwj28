extends Control

export ( int ) var index = 0 


func set_texture( texture: Texture ) -> void:
	$item.texture = texture


func set_can_buy( can_buy: bool ) -> void:
	$buy_button.disabled = !can_buy
	$item.self_modulate = "ffffff" if can_buy else "747474"


func _on_buy_button_pressed():
	Event.emit_signal( "shop_buy_pressed", index )
