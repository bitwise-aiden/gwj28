class_name Inventory
extends Node2D


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
		
		self.display.set_texture( pickup.texture )
		self.display.set_quantity( self.quantity )
	
	
	func increment_quantity( amount: int = 1 ):
		self.quantity += amount
		self.display.set_quantity( self.quantity )
	
	func is_empty():
		return self.pickup_resource == null
	
	func select():
		self.display.set_texture( null )
		self.display.set_quantity( 0 )
		
	func unselect():
		if !self.is_empty():
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

var max_inventory_size = 10
var inventory_slots = []

var selected_inventory_slot = null
var hovered_inventory_slot = null

var just_released = false


func _ready() -> void:
	Event.connect( "inventory_slot_entered", self, "inventory_slot_entered" )
	Event.connect( "inventory_slot_exited", self, "inventory_slot_exited" )
	Event.connect( "inventory_slot_selected", self, "inventory_slot_selected" )
	Event.connect( "pick_up_coin", self, "pick_up_coin" )
	Event.connect( "pick_up_item", self, "pick_up_item" )
	
	var display_slots = $inventory_slots/row_0.get_children() + $inventory_slots/row_1/.get_children() 
	for display_slot in display_slots:
		inventory_slots.append( InventorySlot.new( display_slot ) )


func _process( delta: float ) -> void:
	self.handle_selected_slot()


func handle_selected_slot() -> void:
	if self.selected_inventory_slot == null:
		return
	
	if !Input.is_mouse_button_pressed( BUTTON_LEFT ):
		if self.hovered_inventory_slot:
			self.selected_inventory_slot.swap( 
				self.inventory_slots[ self.hovered_inventory_slot ] 
			)
		else:
			self.selected_inventory_slot.unselect()
		
		self.selected_inventory_slot = null
		self.hovered_inventory_slot = null
		self.just_released = false


func inventory_slot_exited( index ): 
	self.hovered_inventory_slot = null


func inventory_slot_entered( index ):
	print('changed')
	self.hovered_inventory_slot = index


func inventory_slot_selected( index ):
	if self.inventory_slots[ index ].is_empty():
		return
	
	self.selected_inventory_slot = self.inventory_slots[ index ]
	self.selected_inventory_slot.select()


func pick_up_coin( pickup ) -> void:
	self.coin_count += pickup.quantity


func pick_up_item( pickup ) -> void:
	var empty_index = -1
	
	for i in range( self.inventory_slots.size() ):
		if !self.inventory_slots[ i ].is_empty():
			var slot = self.inventory_slots[ i ]
			
			if slot.pickup_resource.name == pickup.name:
				slot.increment_quantity()
				return
		elif empty_index == -1:
			empty_index = i
	
	if empty_index != -1:
		self.inventory_slots[ empty_index ].add_pickup( pickup )
