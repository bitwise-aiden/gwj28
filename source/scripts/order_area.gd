extends StaticBody2D

const MAX_INGREDIENTS = 3
const MAX_WAIT_TIME = 30.0
const ORDER_CHANCE = 2500

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
		if !DayCycle.is_day_in( self.MAX_WAIT_TIME ):
			return
		
		var current_popularity = InstanceManager.popularity_scorer.popularity
		var chance = max( 1, self.ORDER_CHANCE - current_popularity * 10 )
		if randi() % chance == 0:
			self.update_recipe()
	else:
		self.wait_time_remaining = max( 0.0, self.wait_time_remaining - delta )
		$waiting_progress.value = self.wait_time_remaining / self.MAX_WAIT_TIME
		
		if self.wait_time_remaining == 0.0:
			Event.emit_signal( "order_fulfilled", -self.recipe.size() * 2 )
			self.clear_recipe()


func has_point( point: Vector2 ) -> bool:
	var rect = Rect2(
		$collision.global_position - $collision.shape.extents,
		$collision.shape.extents * 2.0
	)
	
	return rect.has_point( point )


func is_waiting() -> bool:
	return !self.recipe.empty()


func fulfill_order( order: Resource ) -> void:
	var order_items = order.metadata[ "items" ].duplicate()
	var order_score = 0
	
	for item in self.recipe:
		if item.name in order_items && order_items[ item.name ] > 0:
			order_items[ item.name ] -= 1
			order_score += 2
		else: 
			order_score -= 1
	
	for quantity_remaining in order_items.values():
		order_score -= quantity_remaining
		
	var time_deduction = -2 + floor( (self.wait_time_remaining / self.MAX_WAIT_TIME) * 3.0 )
	
	order_score += time_deduction
	
	Event.emit_signal( "order_fulfilled", order_score )
	
	self.clear_recipe()


func clear_recipe() -> void:
	self.recipe.clear()
	
	$waiting_progress.visible = false
	$order_items.visible = false


func update_displayed_recipe() -> void:
	for i in self.items.size():
		if i < self.recipe.size():
			self.items[ i ].texture = self.recipe[ i ].texture
			self.items[ i ].visible = true
		else:
			self.items[ i ].visible = false
	
	$waiting_progress.visible = true
	$order_items.visible = true


func update_recipe() -> void:
	self.recipe.clear()
	
	self.recipe = self.required_ingredients.duplicate()
	for i in range( MAX_INGREDIENTS - self.recipe.size() ):
		if randf() >= 0.5:
			self.recipe.append( self.optional_ingredients[ randi() % self.optional_ingredients.size() ] )
	
	self.wait_time_remaining = self.MAX_WAIT_TIME + 2.0
	
	self.update_displayed_recipe()
