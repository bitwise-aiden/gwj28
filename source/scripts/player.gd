class_name Player
extends KinematicBody2D


var speed: float = 300.0
var can_move: bool = true

var focused_crafting_area = null


func _ready() -> void:
	Event.connect( "crafting_started", self, "crafting_menu_close" )

func _process( delta: float ) -> void:
	self.handle_movement( delta )
	
	if self.focused_crafting_area && Input.is_action_just_pressed( "ui_cancel" ):
		self.crafting_menu_close()


func crafting_menu_open( crafting_area ) -> void:
	if crafting_area.state == CraftingArea.states.adding:
		self.can_move = false
		self.focused_crafting_area = crafting_area
		self.focused_crafting_area.crafting_menu = $ui/crafting_menu
		self.focused_crafting_area.update_ui()
		$ui/inventory.focused_crafting_area = crafting_area
		$ui/inventory.crafting_menu = $ui/crafting_menu
		$ui/crafting_menu.focused_crafting_area = crafting_area
		$ui/crafting_menu.visible = true


func crafting_menu_close() -> void:
	self.can_move = true
	self.focused_crafting_area = null
	$ui/inventory.focused_crafting_area = null
	$ui/crafting_menu.focused_crafting_area = null
	$ui/crafting_menu.visible = false
	

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
	
	var collision = self.move_and_collide( direction * self.speed * delta )
	if !collision: 
		return

	if collision.collider is CraftingArea:
		self.crafting_menu_open( collision.collider )
