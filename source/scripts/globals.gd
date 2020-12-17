extends Node

# Chicken globals
const CHICKEN_CHANGE_DIRECTION_CHANCE = 100
const CHICKEN_SPAWN_COIN_CHANCE = 1000
const CHICKEN_SPAWN_EGG_CHANCE = 1000
const CHICKEN_SPEED = 50.0
const CHICKEN_SPEED_MODIFER_MAX = 3.0


# Crafting globals
const CRAFTING_AUTO_START = true
const CRAFTING_COOKING_TIME = 3.0
const CRAFTING_MAX_SIZE = 3


# Instances
var camera = null
var inventory = null
var main = null
var player = null
var popularity_scorer = null
var shop = null
var ui = null


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
const ORDER_PRICE_MULTIPLIER = 1
const ORDER_SCORE_CORRECT_ITEM = 2
const ORDER_SCORE_EXTRA_ITEM = -1
const ORDER_SCORE_MISSING_ITEM = -1
const ORDER_SCORE_WAIT_TIME_EXCEEDED_PER_ITEM = -3
const ORDER_WAIT_TIME_GRACE_PERIOD = 5.0


# Player globals
const PLAYER_SPEED = 400.0


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
var SCENE_PICKUP = load( "res://source/scenes/pickup.tscn" )
var SCENE_STAR = load( "res://source/scenes/star.tscn" )


# Screen globals
const SCREEN_HEIGHT = 600
const SCREEN_WIDTH = 1024


# Star globals
const STAR_MAX_SPEED = 10


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
