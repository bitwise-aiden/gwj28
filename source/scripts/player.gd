class_name Player
extends KinematicBody2D


var speed: float = 400.0
var can_move: bool = true

var focused_crafting_area = null

onready var shadow_size = 16
var oscillation_time_elapsed = 0.0

var ui = null

func _ready() -> void:
	InstanceManager.player = self
	
	Event.connect( "crafting_started", self, "crafting_menu_close" )
	Event.connect( "crafting_close_pressed", self, "crafting_menu_close")
		
	self.ui = InstanceManager.ui
	self.ui.inventory.owning_player = self

func _process( delta: float ) -> void:
	self.handle_movement( delta )
	
	if self.focused_crafting_area && Input.is_action_just_pressed( "ui_cancel" ):
		self.crafting_menu_close()
	
	self.oscillation_time_elapsed += delta * 5.0
	$sprite.position.y = sin( self.oscillation_time_elapsed ) * 2.0
	
	var offset = sin( -self.oscillation_time_elapsed ) * 0.5 + 0.5
	
	$shadow.rect_size.x = self.shadow_size - offset * 6.0
	$shadow.rect_position.x = -self.shadow_size * 0.5 + offset * 3.0

func can_pickup( pickup ) -> bool:
	return self.ui.inventory.can_pickup( pickup )


func crafting_menu_open( crafting_area ) -> void:
	if crafting_area.state == CraftingArea.states.adding:
		self.can_move = false
		self.focused_crafting_area = crafting_area
		self.focused_crafting_area.crafting_menu = self.ui.crafting_menu
		self.focused_crafting_area.update_ui()
		self.ui.inventory.focused_crafting_area = crafting_area
		self.ui.inventory.crafting_menu = self.ui.crafting_menu
		self.ui.crafting_menu.focused_crafting_area = crafting_area
		self.ui.crafting_menu.visible = true


func crafting_menu_close() -> void:
	self.can_move = true
	self.focused_crafting_area = null
	self.ui.inventory.focused_crafting_area = null
	self.ui.crafting_menu.focused_crafting_area = null
	self.ui.crafting_menu.visible = false
	

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
	
	var collision = self.move_and_collide( direction * self.speed * delta )
	if !collision: 
		return

	if collision.collider is CraftingArea:
		self.crafting_menu_open( collision.collider )
