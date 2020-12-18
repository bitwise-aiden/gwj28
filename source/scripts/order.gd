class_name Order

var id = 0

var fulfilled = false
var ingredients = []
var wait_time_remaining = 0.0

var order_pickup = null


func _init( id: int, ingredients: Array ) -> void:
	self.id = id
	self.ingredients = ingredients
	self.wait_time_remaining = (
		Globals.ORDER_MAX_WAIT_TIME + 
		Globals.ORDER_WAIT_TIME_GRACE_PERIOD
	)


func process( delta: float ) -> bool:
	self.wait_time_remaining = max( 0.0, self.wait_time_remaining - delta )

	if self.wait_time_remaining == 0.0:
		Event.emit_signal( "order_fulfilled", 1 )
		self.fulfilled = true
	
	return self.fulfilled


func texture_at( index: int ):
	return self.ingredients[ index ].texture


func size() -> int: 
	return self.ingredients.size()


func waiting_progress() -> float:
	return self.wait_time_remaining / Globals.ORDER_MAX_WAIT_TIME


func fulfill_order( order: Resource ) -> void:
	var order_items = order.metadata[ "items" ].duplicate()
	
	var correct_items = 0.0
	for item in self.ingredients:
		if item.name in order_items && order_items[ item.name ] > 0:
			order_items[ item.name ] -= 1
			correct_items += 1.0
	
	var correctness_ratio = min( 
		correct_items / self.ingredients.size(), 
		1.0 
	)
	var correctness_score = ceil( correctness_ratio * 5.0 )
	
	var time_ratio = min( 
		self.wait_time_remaining / Globals.ORDER_MAX_WAIT_TIME,
		1.0
	)
	var time_score = ceil( time_ratio * 5.0 )

	var total_score = int( ( correctness_score  + time_score ) / 2.0 )
	
	self.fulfilled = true
	Event.emit_signal( "order_fulfilled", total_score )
	
	var coin = Globals.RESOURCE_COIN.duplicate()
	coin.quantity = self.ingredients.size() * Globals.ORDER_PRICE_MULTIPLIER
	
	Event.emit_signal( "pick_up_coin", coin )

