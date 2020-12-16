class_name CraftingArea
extends StaticBody2D

export(Vector2) var done_direction = Vector2.UP

enum states { adding = 0, cooking, done }

var state = states.adding

var item_count = 0
var crafting_menu = null

var items = []


func _process( delta ):
	match self.state:
		states.cooking:
			$cooking_progress.value = 1.0 - (
				$cooking_timer.time_left / 
				Globals.CRAFTING_COOKING_TIME
			)


func add_item( pickup ) -> bool:
	if self.items.size() == Globals.CRAFTING_MAX_SIZE: 
		return false
	
	self.items.append( pickup )
	
	self.update_ui()
	
	if self.should_start_cooking():
		self.start_cooking()
	
	return true


func should_start_cooking() -> bool:
	return (
		Globals.CRAFTING_AUTO_START && 
		self.items.size() == Globals.CRAFTING_MAX_SIZE
	)


func start_cooking():
	if self.items.empty():
		return
		
	self.state = states.cooking
	$cooking_timer.start( Globals.CRAFTING_COOKING_TIME )
	$cooking_progress.visible = true
		
	Event.emit_signal( "crafting_started" )


func update_ui(): 
	if self.crafting_menu:
		self.crafting_menu.update_ui( items )


func _on_cooking_timer_complete():
	var position = self.global_position + self.done_direction * 25.0
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
