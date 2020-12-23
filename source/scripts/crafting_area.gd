class_name CraftingArea
extends StaticBody2D

export(Vector2) var done_direction = Vector2.UP

enum states { adding = 0, cooking, done }

var state = states.adding

var item_count = 0

var items = []


func _process( delta ):
	match self.state:
		states.cooking:
			$cooking_progress.value = 1.0 - (
				$cooking_timer.time_left / 
				Globals.CRAFTING_COOKING_TIME
			)


func add_item( pickup ) -> bool:
	if self.state == states.cooking:
		return false
	
	if self.items.size() == Globals.CRAFTING_MAX_SIZE: 
		return false
	
	self.items.append( pickup )
	
	$key.show_inventory_keys( true ) 
	
#	self.update_ui()
	
	if self.should_start_cooking():
		self.start_cooking()
	
	return true


func should_start_cooking() -> bool:
	return (
		Globals.CRAFTING_AUTO_START && 
		self.items.size() == Globals.CRAFTING_MAX_SIZE
	)

func start_cooking():
	if self.items.empty() || self.state == states.cooking:
		return
		
	self.state = states.cooking
	$cooking_timer.start( Globals.CRAFTING_COOKING_TIME )
	$cooking_progress.visible = true
	$crafting_slots.visible = false
	$pan.play( "cooking" )
	
	$key.show_inventory_keys( false )
	Event.emit_signal( "show_inventory_keys", false )
	
	if Globals.tutorial_current_stage == 8:
		Globals.advance_tutorial( 9 )


func update_ui( override_visibility = true): 
	$crafting_slots.visible = (
		self.state == states.adding &&
		( override_visibility || !self.items.empty() )
	)
	$crafting_slots.update_items( self.items )
	
	if self.state == states.adding:
		$pan.play( "idle" )


func _on_cooking_timer_complete():
	$finished.play(0.5)
	
	var position = self.position + self.done_direction * 30.0
	var pickup = Globals.RESOURCE_OMELETTE.duplicate()
	var items_with_count = {}
	
	for item in self.items:
		if !item.name in items_with_count:
			items_with_count[ item.name ] = 0
		items_with_count[ item.name ] += 1
	
	var item_names = items_with_count.keys()
	item_names.sort()
	for item in item_names:
		pickup.name += "\n - %d x %s" % [ items_with_count[ item ], item ]
	
	pickup.metadata[ "items" ] = items_with_count
	
	Globals.spawn_pickup( pickup, position )
	
	self.items.clear()
	self.state = states.adding
	$cooking_progress.visible = false
	$pan.play( "empty" )
	
	
	self.update_ui( Globals.player.focused_crafting_area == self )
