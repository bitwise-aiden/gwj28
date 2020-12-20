class_name OrderPickupArea
extends StaticBody2D


var order_pickup_arrived = false
var order = null


func _ready():
	self.add_to_group( "order_pickup_area" )
	self.modulate = Color.gray


func pre_fulfill() -> bool:
	if !self.order:
		return false
	
	if self.order.pre_fulfilled: 
		return false
		
	self.order.pre_fulfilled = true
	return true

func fulfill_order( item: Resource ) -> void:
	self.order.fulfill_order( item )
	
	if Globals.tutorial_current_stage == 13: 
		Globals.advance_tutorial( 14 )
	
	if Globals.tutorial_current_stage == 17:
		if Globals.tutorial_extra_ingredient in item.metadata[ "items" ]:
			Globals.advance_tutorial( 18 )


func has_order() -> bool:
	return !!self.order


func is_waiting() -> bool:
	return self.order_pickup_arrived


func order_complete() -> bool:
	return self.order.fulfilled


func set_order( incoming_order ) -> void:
	self.order_pickup_arrived = false
	self.order = incoming_order
