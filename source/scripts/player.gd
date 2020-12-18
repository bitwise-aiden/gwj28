class_name Player
extends KinematicBody2D


const shadow_size = 16

var can_move: bool = true
var focused_crafting_area = null
var focusing_shop = false
var oscillation_time_elapsed = 0.0

var focused_order_pickup_areas = []


func _ready() -> void:
	Globals.player = self
	
	Event.connect( "crafting_started", self, "crafting_menu_close" )
	Event.connect( "crafting_close_pressed", self, "crafting_menu_close")
	Event.connect( "shop_close_pressed", self, "shop_close" )
	
	Globals.ui.inventory.owning_player = self


func _process( delta: float ) -> void:
	self.handle_movement( delta )
	
	if Input.is_action_just_pressed( "ui_cancel" ):
		self.crafting_menu_close()
		self.shop_close()
	
	if self.focused_crafting_area:
		if Input.is_action_just_pressed( "ui_accept" ):
			if self.can_move:
				self.crafting_menu_open( self.focused_crafting_area )
			elif Globals.is_keyboard():
				self.focused_crafting_area.start_cooking()
		elif Globals.is_controller() && \
				Input.is_action_just_pressed( "controller_cook" ):
			self.focused_crafting_area.start_cooking()
	
	if self.focusing_shop && \
			Input.is_action_just_pressed( "ui_accept" ):
		if self.can_move:
			self.shop_open()
		
	
	self.oscillation_time_elapsed += delta * 5.0
	$sprite.position.y = sin( self.oscillation_time_elapsed ) * 2.0
	
	var offset = sin( -self.oscillation_time_elapsed ) * 0.5 + 0.5
	
	$shadow.rect_size.x = self.shadow_size - offset * 6.0
	$shadow.rect_position.x = -self.shadow_size * 0.5 + offset * 3.0


func can_pickup( pickup ) -> bool:
	return Globals.ui.inventory.can_pickup( pickup )


func crafting_menu_open( crafting_area ) -> void:
	if crafting_area.state == CraftingArea.states.adding:
		self.can_move = false
#		self.focused_crafting_area = crafting_area
		self.focused_crafting_area.crafting_menu = Globals.ui.crafting_menu
		self.focused_crafting_area.update_ui()
		Globals.ui.inventory.focused_crafting_area = crafting_area
		Globals.ui.inventory.crafting_menu = Globals.ui.crafting_menu
		Globals.ui.crafting_menu.focused_crafting_area = crafting_area
		Globals.ui.crafting_menu.visible = true


func crafting_menu_close() -> void:
	self.can_move = true
#	self.focused_crafting_area = null
	Globals.ui.inventory.focused_crafting_area = null
	Globals.ui.crafting_menu.focused_crafting_area = null
	Globals.ui.crafting_menu.visible = false


func shop_open() -> void:
	self.can_move = false
	Globals.ui.shop_menu.visible = true
	Globals.ui.shop_menu.update_shop_display()


func shop_close() -> void:
	self.can_move = true
	Globals.ui.shop_menu.visible = false


func handle_movement( delta: float ) -> void:
	if !can_move:
		return
	var start_position = self.position 
	
	var movement_horizontal = Vector2(
		Input.get_action_strength( "ui_right" ) -
		Input.get_action_strength( "ui_left" ),
		0.0
	)
	
	var movement_vertical = Vector2(
		0.0,
		Input.get_action_strength( "ui_down" ) -
		Input.get_action_strength( "ui_up" )
	)
	
	var direction = ( movement_vertical + movement_horizontal ).normalized()
	
	if direction.length() == 0.0:
		return
		
	if direction.x < 0:
		$sprite.scale.x = 1
	elif direction.x > 0:
		$sprite.scale.x = -1
		
	var movement_offset = direction * Globals.PLAYER_SPEED * delta
	
	var collision = self.move_and_collide( 
		 movement_offset
	)	
	if self.handle_collision( collision ):
		return 

	# If moving on horizontal and vertical
	if movement_horizontal.length() && movement_vertical.length():
		# Calculate vector from start of frame position
		var direction_delta = (self.position - start_position)
		# If distance is less than intended movement 
		if movement_offset.length() > direction_delta.length():
			# Calculate how much movement should remain
			var remaining_amount = movement_offset.length() - direction_delta.length()
			# Determine direction remaining should be in
			var remaining_direction = movement_horizontal
			if collision.normal == -movement_horizontal:
				remaining_direction = movement_vertical
			
			# Proceed to move
			collision = self.move_and_collide( remaining_direction * remaining_amount )
	
	self.handle_collision( collision )


func handle_collision( collision ) -> bool:
	if !collision:
		return true
	
	if !Globals.PLAYER_OPEN_WHEN_COLLIDING:
		return false 
	
	if collision.collider is CraftingArea:
		self.crafting_menu_open( collision.colider )
		return true
	
	if collision.collider is Shop:
		self.shop_open()
		return true
	
	return false
	
	
func update_inventory_order_area() -> void:
	var min_distance = 10000.0
	var min_order_area = null
	
	var player_position = self.position + Vector2( 0.0, 20.0 )
	
	for order_area in self.focused_order_pickup_areas:
		var distance = ( player_position - order_area.position ).length()
		if distance < min_distance:
			min_distance = distance
			min_order_area = order_area
		
		order_area.modulate = Color.gray
	
	if min_order_area:
		min_order_area.modulate = Color.white
	
	Globals.ui.inventory.focused_order_area = min_order_area


func _on_interaction_area_body_entered(body):
	if body is CraftingArea:
		self.focused_crafting_area = body
	
	if body is Shop: 
		self.focusing_shop = true
		
	if body is OrderPickupArea:
		self.focused_order_pickup_areas.append( body )
		self.update_inventory_order_area()


func _on_interaction_area_body_exited(body):
	if body is CraftingArea:
		self.focused_crafting_area = null
	
	if body is Shop: 
		self.focusing_shop = false

	if body is OrderPickupArea:
		var index = self.focused_order_pickup_areas.find( body )
		self.focused_order_pickup_areas.remove( index )
		self.update_inventory_order_area()
		
		body.modulate = Color.gray
