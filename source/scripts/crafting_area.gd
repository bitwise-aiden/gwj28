class_name CraftingArea
extends StaticBody2D

export(Vector2) var done_direction = Vector2.UP
onready var pickup_scene = load( "res://source/scenes/pickup.tscn" )
onready var pickup_omelette_resource = load( "res://source/resources/pickups/pickup_omelette.tres" )

const MAX_SIZE = 10
const COOKING_TIME = 5.0

enum states { adding = 0, cooking, done }

var state = states.adding

var item_count = 0
var crafting_menu = null

var items = []

func _process( delta ):
	match self.state:
		states.cooking:
			$cooking_progress.value = 1.0 - ($cooking_timer.time_left / self.COOKING_TIME)


func add_item( pickup ) -> bool:
	if self.items.size() == self.MAX_SIZE: 
		return false
	
	self.items.append( pickup )
	
	self.update_ui()
	
	if self.items.size() == self.MAX_SIZE:
		self.start_cooking()
	
	return true


func start_cooking():
	if self.items.empty():
		return
		
	self.state = states.cooking
	$cooking_timer.start( self.COOKING_TIME )
	$cooking_progress.visible = true
		
	Event.emit_signal( "crafting_started" )


func update_ui(): 
	if self.crafting_menu:
		self.crafting_menu.update_ui( items )


func _on_cooking_timer_complete():
	var instance = self.pickup_scene.instance()
	instance.position = self.global_position + self.done_direction * 25.0
	instance.pickup_resource = self.pickup_omelette_resource
	# TODO: Add item list for pickup 
	
	self.get_parent().call_deferred( "add_child", instance )
	
	self.items.clear()
	self.state = states.adding
	$cooking_progress.visible = false
