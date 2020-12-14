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
		
		self.display.set_texture( pickup.texture )
		self.display.set_quantity( self.quantity )
	
	
	func increment_quantity( update_display: int = true ):
		self.quantity += 1
		if update_display:
			self.display.set_quantity( self.quantity )
	
	func decrement_quantity():
		self.quantity -= 1
		if self.quantity <= 0:
			self.pickup_resource = null
			self.select()
			
	
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

var focused_crafting_area = null
onready var crafting_menu = null


func _ready() -> void:
	Event.connect( "pick_up_coin", self, "pick_up_coin" )
	Event.connect( "pick_up_item", self, "pick_up_item" )
	
	for display_slot in $slots.get_children() :
		inventory_slots.append( InventorySlot.new( display_slot ) )


func _process( delta: float ) -> void:
	self.handle_selected_slot()


func handle_selected_slot() -> void:
	$selected_item.global_position = self.get_global_mouse_position()
	
	if Input.is_action_just_pressed( "mouse" ):
		self.select_slot()
	elif Input.is_action_just_released( "mouse" ):
		self.unselect_slot()


func find_hovered_slot():
	var mouse_position = self.get_global_mouse_position()
	
	for slot in self.inventory_slots:
		if slot.display.has_point( mouse_position ):
			return slot
	
	return null


func select_slot():
	var selected_slot = self.find_hovered_slot()
	if !selected_slot || selected_slot.is_empty():
		return

	self.selected_inventory_slot = selected_slot
	self.selected_inventory_slot.select()

	$selected_item.texture = self.selected_inventory_slot.pickup_resource.texture
	$selected_item.visible = true


func unselect_slot():
	if self.selected_inventory_slot == null:
		return
		
	if !self.drop_in_crafting_area():
		var hovered_inventory_slot = self.find_hovered_slot()
		
		if hovered_inventory_slot:
			self.selected_inventory_slot.swap( 
				hovered_inventory_slot
			)
	
	self.selected_inventory_slot.unselect()
	
	self.selected_inventory_slot = null
	$selected_item.visible = false


func drop_in_crafting_area():
	if !self.focused_crafting_area:
		return false
	
	var mouse_position = self.get_global_mouse_position()
	if !self.crafting_menu.has_point( mouse_position ):
		return false
		
	if !self.focused_crafting_area.add_item(
			self.selected_inventory_slot.pickup_resource ):
		return false 

	self.selected_inventory_slot.decrement_quantity()
	
	return true


func pick_up_coin( pickup ) -> void:
	self.coin_count += pickup.quantity


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
