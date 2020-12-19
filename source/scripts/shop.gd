class_name Shop
extends StaticBody2D


# list of items that can be purchase
# the amount they can be purchased for 
# deplete money in inventory

export (Array, Resource) var items = []
export ( Vector2 ) var spawn_direction = Vector2.DOWN

var controller_selected_slot = 0


func _ready():
	Globals.shop = self
	
	Event.connect( "shop_buy_pressed", self, "shop_buy_pressed" )


func _process(delta):
	if !Globals.ui.shop_menu.visible:
		return
	
	var max_items = self.items.size()
	
	if Input.is_action_just_pressed( "scroll_left" ):
		self.controller_selected_slot = ( max_items + self.controller_selected_slot - 1 ) % max_items
		Globals.ui.shop_menu.update_controller_ui( self.controller_selected_slot )
	
	if Input.is_action_just_pressed( "scroll_right" ):
		self.controller_selected_slot = ( self.controller_selected_slot + 1 ) % max_items
		Globals.ui.shop_menu.update_controller_ui( self.controller_selected_slot )

	if Globals.is_controller() && \
			Input.is_action_just_pressed( "ui_accept" ):
		self.shop_buy_pressed( self.controller_selected_slot )
	
	for i in range( max_items ):
		if Input.is_action_just_pressed( String( i + 1 ) ):
			self.shop_buy_pressed( i )
			break 


func shop_buy_pressed( index ):
	var item = self.items[ index ] 
	if item.stock == 0:
		return 
		
	if Globals.tutorial_current_stage == 16: 
		if item.name != Globals.tutorial_extra_ingredient:
			return 
		Globals.advance_tutorial( 17 )
		
	self.items[ index ].stock -= 1
	
	if Globals.inventory.buy( item.price ):
		Globals.spawn_pickup( item, self.position + spawn_direction * 50.0 )
		
		Globals.ui.shop_menu.update_shop_display()
