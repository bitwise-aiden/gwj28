class_name Player
extends KinematicBody2D


const shadow_size = 16

var can_move: bool = true
var focused_crafting_area = null
var oscillation_time_elapsed = 0.0


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
		self.focused_crafting_area = crafting_area
		self.focused_crafting_area.crafting_menu = Globals.ui.crafting_menu
		self.focused_crafting_area.update_ui()
		Globals.ui.inventory.focused_crafting_area = crafting_area
		Globals.ui.inventory.crafting_menu = Globals.ui.crafting_menu
		Globals.ui.crafting_menu.focused_crafting_area = crafting_area
		Globals.ui.crafting_menu.visible = true


func crafting_menu_close() -> void:
	self.can_move = true
	self.focused_crafting_area = null
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
	
	var direction = Vector2(
		Input.get_action_strength( "right" ) -
		Input.get_action_strength( "left" ),
		Input.get_action_strength( "down" ) -
		Input.get_action_strength( "up" )
	).normalized()
	
	if direction.length() == 0.0:
		return
		
	if direction.x < 0:
		$sprite.scale.x = 1
	elif direction.x > 0:
		$sprite.scale.x = -1
	
	var collision = self.move_and_collide( 
		direction * Globals.PLAYER_SPEED * delta 
	)
	if !collision: 
		return

	if collision.collider is CraftingArea:
		self.crafting_menu_open( collision.collider )

	if collision.collider is Shop:
		self.shop_open()
