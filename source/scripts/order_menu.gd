extends Node


export (Array, Resource) var required_ingredients = []
export (Array, Resource) var optional_ingredients = []

onready var order_displays = self.get_children()

var order_index = 1000
var orders = []
var order_creation_time_out = 0.0

func _ready() -> void:
	Globals.order_menu = self


func _process( delta: float ) -> void:
	if !Globals.first_egg:
		return
	
	var number_of_orders = self.orders.size()
	
	var popularity = Globals.popularity_scorer.popularity
	
	var max_orders = 1 + floor( 
		popularity / Globals.ORDER_POPULARITY_EXTRA_ORDER 
	)
	max_orders = max( 1, min( Globals.ORDER_MAX_ORDERS, max_orders ) )
	
	
	var order_creation_chance = int( max( 0.0, 
		Globals.ORDER_CREATION_CHANCE - 
		popularity * Globals.ORDER_POPULARITY_MULTIPLIER
	) )
	
	var extra_ingredient_chance = 1.0 - min( 
		popularity / Globals.ORDER_POPULARITY_EXTRA_INGREDIENT, 1.0 
	)
	
	if self.orders.size() < max_orders:
		self.order_creation_time_out = max( 0.0, self.order_creation_time_out - delta )
		
		if randi() % order_creation_chance == 0 || \
			self.order_creation_time_out == 0.0:
			var ingredients = self.required_ingredients.duplicate()
			
			for i in range( Globals.ORDER_MAX_SIZE - self.orders.size() ):
				if randf() >= extra_ingredient_chance:
					var ingredient = randi() % self.optional_ingredients.size()
					ingredients.append( 
						self.optional_ingredients[ ingredient ] 
					)
			
			self.order_creation_time_out = Globals.ORDER_CREATION_TIME_OUT
			self.order_index += 1
			orders.append( Order.new( self.order_index, ingredients ) )
	
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


func get_order_for_pickup() -> Order:
	for order in self.orders:
		if order.order_pickup == null:
			return order
	
	return null
