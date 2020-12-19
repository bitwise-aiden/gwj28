class_name Inventory
extends Control


class InventorySlot:
	var display
	var pickup_resource
	var quantity
	
	
	func _init( display ):
		self.display = display
		self.pickup_resource = null
		self.quantity = null
	
	
	func add_pickup( pickup ):
		self.pickup_resource = pickup
		self.quantity = 1
		
		self.unselect()
	
	
	func increment_quantity( update_display: int = true ):
		self.quantity += 1
		if update_display:
			self.display.set_quantity( self.quantity )
	
	
	func decrement_quantity():
		self.quantity -= 1
		if self.quantity <= 0:
			self.pickup_resource = null
			self.select()
		else:
			self.unselect()
			
	
	func is_empty():
		return self.pickup_resource == null
	
	
	func select():
		self.display.set_texture( null )
		self.display.set_quantity( 0 )
	
	
	func unselect():
		if !self.is_empty():
			if self.pickup_resource.orderable:
				var omelette_keys = self.pickup_resource.metadata[ "items" ] 
				var omelette_items = []
				
				for key in omelette_keys:
					var count = self.pickup_resource.metadata[ "items" ][ key ]
					for i in range( count ):
						omelette_items.append( key )
						
				omelette_items.sort_custom( Globals, "sort_item_names" )
				
				self.display.set_omelette( omelette_items )
			else:
				self.display.set_texture( self.pickup_resource.texture )
			self.display.set_quantity( self.quantity )
		else:
			self.select()
	
	
	func swap( other_slot ): 
		if self == other_slot:
			self.unselect()
			return
		
		var new_pickup = other_slot.pickup_resource
		var new_quantity = other_slot.quantity
	
		other_slot.pickup_resource = self.pickup_resource
		other_slot.quantity = self.quantity
		other_slot.unselect()
		
		self.pickup_resource = new_pickup
		self.quantity = new_quantity
		self.unselect()

var coin_count = 0
var inventory_slots = []

var selected_inventory_slot = null

var focused_crafting_area = null
var focused_order_area = null


func _ready() -> void:
	Globals.inventory = self
	
	Event.connect( "pick_up_coin", self, "pick_up_coin" )
	Event.connect( "pick_up_item", self, "pick_up_item" )
	
	for display_slot in $slots.get_children():
		inventory_slots.append( InventorySlot.new( display_slot ) )
	
	$inventory_coins/coins.text = "%d" % [ self.coin_count ]


func _process( delta: float ) -> void:
	for i in range( 5 ):
		if Input.is_action_just_pressed( String( i + 1 ) ):
			self.add_item_to_crafting_area( i )
			self.add_item_to_order_area( i )
			break 
	
	if !Globals.ui.shop_menu.visible:
		if Globals.is_controller() && \
				Input.is_action_just_pressed( "ui_accept" ):
			self.add_item_to_crafting_area( self.selected_inventory_slot )
			self.add_item_to_order_area( self.selected_inventory_slot )
		
		if Input.is_action_just_pressed( "scroll_left" ):
			self.selected_inventory_slot = ( 5 + self.selected_inventory_slot - 1 ) % 5
			self.update_controller_ui()
		
		if Input.is_action_just_pressed( "scroll_right" ):
			self.selected_inventory_slot = ( self.selected_inventory_slot + 1 ) % 5
			self.update_controller_ui()


func buy( amount: int ) -> bool:
	if self.coin_count >= amount:
		self.coin_count -= amount
		$inventory_coins/coins.text = "%d" % [ self.coin_count ]
		return true
	return false


func can_buy( amount: int ) -> bool:
	return self.coin_count >= amount


func can_pickup( pickup ) -> bool:
	for i in range( self.inventory_slots.size() ):
		if self.inventory_slots[ i ].is_empty() || \
			self.inventory_slots[ i ].pickup_resource.name == pickup.name:
			return true
	return false


func add_item_to_crafting_area( slot_index: int ) -> void:
	if !self.focused_crafting_area:
		return
	
	
	var slot = self.inventory_slots[ slot_index ]
	
	if self.inventory_slots[ slot_index ].is_empty():
		return 
	
	var pickup = self.inventory_slots[ slot_index ].pickup_resource
	
	if !pickup.craftable:
		return
	
	if !self.focused_crafting_area.add_item( pickup ):
		return 
	
	self.inventory_slots[ slot_index ].decrement_quantity()
	self.lerp_item(  
		pickup, 
		self.inventory_slots[ slot_index ].display.rect_global_position + Vector2( 32.0, 0.0 ), 
		self.focused_crafting_area.position,
		Task.RunFunc.new( funcref( self.focused_crafting_area, "update_ui" ) )
	)


func add_item_to_order_area( slot_index: int ) -> void:
	if !self.focused_order_area:
		return 
	
	if !self.focused_order_area.is_waiting():
		return
	
	var slot = self.inventory_slots[ slot_index ]
	
	if self.inventory_slots[ slot_index ].is_empty():
		return 
	
	var pickup = self.inventory_slots[ slot_index ].pickup_resource
	
	if !pickup.orderable:
		return
		
#	self.focused_order_area.fulfill_order( pickup )
	self.inventory_slots[ slot_index ].decrement_quantity()
	
	self.lerp_item( 
		pickup, 
		self.inventory_slots[ slot_index ].display.rect_global_position + Vector2( 32.0, 0.0 ),
#		Globals.player.position,
		self.focused_order_area.position,
		Task.RunFunc.new( funcref( self.focused_order_area, "fulfill_order" ), [ pickup ] )
	)


func lerp_item( item, from: Vector2, to: Vector2, post_task: BaseTask ) -> void:
	print(from, to)
	for pickup_lerper in self.get_tree().get_nodes_in_group( "pickup_lerper" ):
		print( pickup_lerper, pickup_lerper.visible )
		if !pickup_lerper.visible:
			pickup_lerper.lerp_texture( item.texture, from, to, 0.3 )
			TaskManager.add_queue( 
				pickup_lerper.name,
				post_task
			)
			return 
	
	TaskManager.add_queue(
		self.name,
		post_task
	)


func pick_up_coin( pickup ) -> void:
	self.coin_count += pickup.quantity
	$inventory_coins/coins.text = "%d" % [ self.coin_count ]


func pick_up_item( pickup ) -> void:
	var empty_index = -1
	
	for i in range( self.inventory_slots.size() ):
		if !self.inventory_slots[ i ].is_empty():
			var slot = self.inventory_slots[ i ]
			
			if slot.pickup_resource.name == pickup.name:
				slot.increment_quantity( slot != self.selected_inventory_slot )
				return
		elif empty_index == -1:
			empty_index = i
	
	if empty_index != -1:
		self.inventory_slots[ empty_index ].add_pickup( pickup )


func update_controller_ui():
	for i in range( self.inventory_slots.size() ):
		if self.selected_inventory_slot == i: 
			self.inventory_slots[ i ].display.modulate = Color.white
		else:
			self.inventory_slots[ i ].display.modulate = Color("b0b0b0")
