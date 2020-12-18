class_name OrderPickupArea
extends StaticBody2D


var order_pickup_arrived = false
var order = null


func _ready():
	self.add_to_group( "order_pickup_area" )
	self.modulate = Color.gray


func fulfill_order( item: Resource ) -> void:
	self.order.fulfill_order( item )


func has_order() -> bool:
	return !!self.order


func has_point( point: Vector2 ) -> bool:
	var rect = Rect2(
		self.position - $collision.shape.extents,
		$collision.shape.extents * 2.0
	)
	
	return rect.has_point( point )


func is_waiting() -> bool:
	return self.order_pickup_arrived


func order_complete() -> bool:
	return self.order.fulfilled


func set_order( incoming_order ) -> void:
	self.order_pickup_arrived = false
	self.order = incoming_order
