extends Node


export (Array, Resource) var required_ingredients = []
export (Array, Resource) var optional_ingredients = []

onready var order_displays = self.get_children()

var orders = []


func _process( delta: float ) -> void:
	var number_of_orders = self.orders.size()
	
	if Globals.ORDER_MAX_ORDERS > self.orders.size():
		if randi() % Globals.ORDER_CREATION_CHANCE == 0:
			var ingredients = self.required_ingredients.duplicate()
			
			for i in range( Globals.ORDER_MAX_SIZE - self.orders.size() ):
				if randf() >= 0.5:
					var ingredient = randi() % self.optional_ingredients.size()
					ingredients.append( 
						self.optional_ingredients[ ingredient ] 
					)
					
			orders.append( Order.new( ingredients ) )
	
	var marked_for_removal = []
	for index in range( self.orders.size() ):
		if self.orders[ index ].process( delta ):
			marked_for_removal.append( index )
	
	marked_for_removal.invert()
	for index in marked_for_removal:
		self.orders.remove( index )
	
	
	if number_of_orders != self.orders.size():
		for index in range( self.order_displays.size() ):
			if index < self.orders.size():
				self.order_displays[ index ].set_order( self.orders[ index ] )
			else: 
				self.order_displays[ index ].set_order()









#func _process( delta: float) -> void:
#	if recipe.empty():
#		var current_popularity = (
#				Globals.popularity_scorer.popularity * 
#				Globals.ORDER_POPULARITY_MULTIPLIER
#			)
#		var chance = max( 1, Globals.ORDER_CHANCE - current_popularity )
#		if randi() % chance == 0:
#			self.update_recipe()
#	else:
#		self.wait_time_remaining = max( 0.0, self.wait_time_remaining - delta )
#		$waiting_progress.value = (
#			self.wait_time_remaining / Globals.ORDER_MAX_WAIT_TIME
#		)
#
#		if self.wait_time_remaining == 0.0:
#			Event.emit_signal( "order_fulfilled", 1 )
#			self.clear_recipe()
#
#
#func update_recipe() -> void:
#	self.recipe.clear()
#
#	self.recipe = self.required_ingredients.duplicate()
#	for i in range( Globals.ORDER_MAX_SIZE - self.recipe.size() ):
#		if randf() >= 0.5:
#			self.recipe.append( self.optional_ingredients[ randi() % self.optional_ingredients.size() ] )
#
#	self.wait_time_remaining = Globals.ORDER_MAX_WAIT_TIME + 2.0

