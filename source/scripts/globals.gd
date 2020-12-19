extends Node

# Chicken globals
const CHICKEN_CHANGE_DIRECTION_CHANCE = 100
const CHICKEN_SPAWN_COIN_CHANCE = 1000
const CHICKEN_SPAWN_EGG_CHANCE = 1000
const CHICKEN_SPEED = 50.0
const CHICKEN_SPEED_MODIFER_MAX = 3.0
const CHICKEN_SPAWN_TOP_LEFT = Vector2( 483.0, -97.0 )
const CHICKEN_SPAWN_BOTTOM_RIGHT = Vector2( 845.0, 214.0 )


# Crafting globals
const CRAFTING_AUTO_START = true
const CRAFTING_COOKING_TIME = 3.0
const CRAFTING_MAX_SIZE = 3


# Instances
var camera = null
var indicator = null
var inventory = null
var main = null
var order_menu = null
var player = null
var popularity_scorer = null
var shop = null
var ui = null
var first_egg = false
var input_type = "keyboard"


# Inventory globals
const INVENTORY_MAX_SIZE = 5


# Location globals
const KITCHEN_Y_LEVEL = 300


# Order globals
const ORDER_CREATION_CHANCE = 2500
const ORDER_CREATION_TIME_OUT = 5.0
const ORDER_MAX_ORDERS = 3
const ORDER_MAX_SIZE = 3
const ORDER_MAX_WAIT_TIME = 30.0
const ORDER_POPULARITY_MULTIPLIER = 10
const ORDER_POPULARITY_EXTRA_ORDER = 3.0
const ORDER_POPULARITY_EXTRA_INGREDIENT = 30.0
const ORDER_PRICE_MULTIPLIER = 1
const ORDER_SCORE_CORRECT_ITEM = 2
const ORDER_SCORE_EXTRA_ITEM = -1
const ORDER_SCORE_MISSING_ITEM = -1
const ORDER_SCORE_WAIT_TIME_EXCEEDED_PER_ITEM = -3
const ORDER_WAIT_TIME_GRACE_PERIOD = 5.0


# Player globals
const PLAYER_SPEED = 400.0
const PLAYER_OPEN_WHEN_COLLIDING = false


# Pickup globals
const PICKUP_ACCELERATION_TIME = 0.5
const PICKUP_MAX_SPEED = 500.0


# Popularity globals
const POPULARITY_MULTIPLIER = 1.0


# Resource globals
var RESOURCE_BACON = load( "res://source/resources/pickups/pickup_bacon.tres" )
var RESOURCE_COIN = load( "res://source/resources/pickups/pickup_coin.tres" )
var RESOURCE_EGG = load( "res://source/resources/pickups/pickup_egg.tres" )
var RESOURCE_OMELETTE = load( "res://source/resources/pickups/pickup_omelette.tres" )


# Scene globals
var SCENE_CHICKEN = load( "res://source/scenes/chicken.tscn" )
var SCENE_PICKUP = load( "res://source/scenes/pickup.tscn" )
var SCENE_STAR = load( "res://source/scenes/star.tscn" )
var SCENE_INDICATOR = load( "res://source/scenes/indicator.tscn" )


# Screen globals
const SCREEN_HEIGHT = 600
const SCREEN_WIDTH = 1024


# Star globals
const STAR_MAX_SPEED = 10


# Tutorial variables
var tutorial_current_stage = 0 
var tutorial_extra_ingredient = ""


func _input( event ):
	var previous = Globals.input_type
	
	if event is InputEventMouseMotion || event is InputEventKey:
		Globals.input_type = "keyboard"
	
	if event is InputEventJoypadButton || event is InputEventJoypadMotion:
		Globals.input_type = "controller"
		
	if previous != Globals.input_type:
		Event.emit_signal( "input_type_changed" )
		
	if self.tutorial_current_stage == 0:
		self.advance_tutorial( 1 )
	


func _ready() -> void:
	randomize()
	
	Event.connect( "pick_up_chicken", self, "spawn_chicken" )


func advance_tutorial( stage: int ) -> bool:
	if self.player && stage != self.tutorial_current_stage + 1:
		return false
	
	
	self.tutorial_current_stage += 1
	
	match self.tutorial_current_stage:
		1: 
			self.indicator.position = Vector2( 672.0, 340.0 )
			self.indicator.rotation = PI
			self.indicator.state = 2
			self.indicator.z_index = 2
			self.indicator.visible = true
		5: 
			self.indicator.position = Vector2( 672.0, 215.0 )
			self.indicator.rotation = 0
			self.indicator.state = 2
			self.indicator.z_index = 2
			self.indicator.visible = true
		6: 
			self.indicator.position = Vector2( 605.0, 420.0 )
			self.indicator.rotation = 0
			self.indicator.state = 2
			self.indicator.z_index = 2
			self.indicator.visible = true
		7: 
			self.indicator.visible = false
		11:
			self.indicator.visible = false
		13: 
			self.indicator.visible = false
		15:
			self.indicator.position = Vector2( 850.0, 400.0 )
			self.indicator.rotation = PI
			self.indicator.state = 2
			self.indicator.z_index = 2
			self.indicator.visible = true
		16: 
			self.indicator.visible = false
			
			
	
	return true


func is_keyboard(): 
	return self.input_type == "keyboard"


func is_controller(): 
	return self.input_type == "controller"


func is_in_kitchen( position: Vector2 ):
	return position.y >= self.KITCHEN_Y_LEVEL


func spawn_pickup( resource: Resource, position: Vector2, 
	is_dropped: bool = false):
	var instance = self.SCENE_PICKUP.instance()
	
	instance.position = position
	instance.pickup_resource = resource
	if is_dropped:
		instance.drop_cooldown = 1.0
	
	self.main.call_deferred( "add_child", instance )


func sort_items(a, b): 
	return sort_item_names( a.name, b.name )


func sort_item_names( a, b ):
	return a.length() < b.length()
	

func spawn_chicken( pickup ):
	var instance = self.SCENE_CHICKEN.instance()
	
	instance.position =  Vector2( 
		lerp( CHICKEN_SPAWN_TOP_LEFT.x, CHICKEN_SPAWN_BOTTOM_RIGHT.x, randf() ),
		lerp( CHICKEN_SPAWN_TOP_LEFT.y, CHICKEN_SPAWN_BOTTOM_RIGHT.y, randf() )
	)
	instance.z_index = 4
	
	self.main.call_deferred( "add_child", instance )
