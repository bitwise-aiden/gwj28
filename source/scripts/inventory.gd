class_name Inventory
extends Node


var coin_count = 0


func _ready() -> void:
	Event.connect( "pick_up_coin", self, "pick_up_coin" )


func pick_up_coin( pickup ) -> void:
	self.coin_count += pickup.quantity
