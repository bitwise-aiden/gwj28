class_name Order

var color = Color.white
var fulfilled = false
var ingredients = []
var pre_fulfilled = false
var should_tick = false
var wait_time_remaining = 0.0

var order_pickup = null


func _init( color: Color, ingredients: Array ) -> void:
	self.color = color
	self.ingredients = ingredients.duplicate()
	self.ingredients.sort_custom( Globals, "sort_items" )
	self.wait_time_remaining = (
		Globals.ORDER_MAX_WAIT_TIME + 
		Globals.ORDER_WAIT_TIME_GRACE_PERIOD
	)


func process( delta: float ) -> bool:
	if !self.should_tick:
		return self.fulfilled
		 
	if self.pre_fulfilled:
		return self.fulfilled
	
	if Globals.tutorial_current_stage < 14: 
		return self.fulfilled
	
	if Globals.tutorial_current_stage < 18 && self.ingredients.back().name != "Egg":
		return self.fulfilled
	
	self.wait_time_remaining = max( 0.0, self.wait_time_remaining - delta )

	if self.wait_time_remaining == 0.0:
		Event.emit_signal( "order_fulfilled", 1 )
		self.fulfilled = true
	
	return self.fulfilled


func name_at( index: int ):
	return self.ingredients[ index ].name


func size() -> int: 
	return self.ingredients.size()


func waiting_progress() -> float:
	return self.wait_time_remaining / Globals.ORDER_MAX_WAIT_TIME


func set_should_tick( should: bool ) -> void:
	self.should_tick = should


func fulfill_order( order: Resource ) -> void:
	var order_items = order.metadata[ "items" ].duplicate()
	
	if !"Egg" in order_items:
		self.fulfilled = true
		Event.emit_signal( "order_fulfilled", 1 )
		return
	
	var correct_items = 0.0
	for item in self.ingredients:
		if item.name in order_items && order_items[ item.name ] > 0:
			order_items[ item.name ] -= 1
			correct_items += 1.0
	
	var correctness_ratio = min( 
		correct_items / self.ingredients.size(), 
		1.0 
	)
	var correctness_score = max( 1.0, ceil( correctness_ratio * 5.0 ) )
	
	var time_ratio = min( 
		self.wait_time_remaining / Globals.ORDER_MAX_WAIT_TIME,
		1.0
	)
	var time_score = ceil( time_ratio * 5.0 )

	var total_score = int( ( correctness_score * 2.0  + time_score ) / 3.0 )
	
	self.fulfilled = true
	Event.emit_signal( "order_fulfilled", total_score )
	
	var coin = Globals.RESOURCE_COIN.duplicate()
	coin.quantity = self.ingredients.size() * Globals.ORDER_PRICE_MULTIPLIER
	
	if total_score == 5:
		coin.quantity += 1
	
	Event.emit_signal( "pick_up_coin", coin )

