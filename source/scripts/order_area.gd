extends VBoxContainer


export (Array, Resource) var required_ingredients = []
export (Array, Resource) var optional_ingredients = []

onready var items = $order_items.get_children()


var recipe = []
var wait_time_remaining = 0.0


func _ready() -> void:
	self.add_to_group( "order_area" )
	
	self.clear_recipe()


func _process( delta: float) -> void:
	if recipe.empty():
		var current_popularity = (
				Globals.popularity_scorer.popularity * 
				Globals.ORDER_POPULARITY_MULTIPLIER
			)
		var chance = max( 1, Globals.ORDER_CHANCE - current_popularity )
		if randi() % chance == 0:
			self.update_recipe()
	else:
		self.wait_time_remaining = max( 0.0, self.wait_time_remaining - delta )
		$waiting_progress.value = (
			self.wait_time_remaining / Globals.ORDER_MAX_WAIT_TIME
		)
		
		if self.wait_time_remaining == 0.0:
			Event.emit_signal( "order_fulfilled", 1 )
			self.clear_recipe()


func has_point( point: Vector2 ) -> bool:
	var rect = Rect2(
		self.rect_global_position,
		self.rect_size
	)
	return rect.has_point( point )


func is_waiting() -> bool:
	return !self.recipe.empty()


func fulfill_order( order: Resource ) -> void:
	var order_items = order.metadata[ "items" ].duplicate()
	
	var correct_items = 0.0
	
	for item in self.recipe:
		if item.name in order_items && order_items[ item.name ] > 0:
			order_items[ item.name ] -= 1
			correct_items += 1.0
	
	var correctness_ratio = min( 
		correct_items / self.recipe.size(), 
		1.0 
	)
	var correctness_score = ceil( correctness_ratio * 5.0 )
	
	var time_ratio = min( 
		self.wait_time_remaining / Globals.ORDER_MAX_WAIT_TIME,
		1.0
	)
	var time_score = ceil( time_ratio * 5.0 )

	var total_score = int( ( correctness_score  + time_score ) / 2.0 )
	
	Event.emit_signal( "order_fulfilled", total_score )
	
	self.clear_recipe()


func clear_recipe() -> void:
	self.recipe.clear()
	
	$waiting_progress.visible = false
	$order_items.visible = false
	self.visible = false


func update_displayed_recipe() -> void:
	for i in self.items.size():
		if i < self.recipe.size():
			self.items[ i ].texture = self.recipe[ i ].texture
			self.items[ i ].visible = true
		else:
			self.items[ i ].visible = false
	
	$waiting_progress.visible = true
	$order_items.visible = true
	self.visible = true


func update_recipe() -> void:
	self.recipe.clear()
	
	self.recipe = self.required_ingredients.duplicate()
	for i in range( Globals.ORDER_MAX_SIZE - self.recipe.size() ):
		if randf() >= 0.5:
			self.recipe.append( self.optional_ingredients[ randi() % self.optional_ingredients.size() ] )
	
	self.wait_time_remaining = Globals.ORDER_MAX_WAIT_TIME + 2.0
	
	self.update_displayed_recipe()
