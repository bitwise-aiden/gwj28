class_name Shop
extends StaticBody2D


# list of items that can be purchase
# the amount they can be purchased for 
# deplete money in inventory

export (Array, Resource) var items = []
export ( Vector2 ) var spawn_direction = Vector2.DOWN


func _ready():
	Globals.shop = self
	
	Event.connect( "shop_buy_pressed", self, "shop_buy_pressed" )


func shop_buy_pressed( index ):
	var item = self.items[ index ] 
	
	Globals.inventory.buy( item.price )
	Globals.spawn_pickup( item, self.position + spawn_direction * 50.0 )
	
	Globals.ui.shop_menu.update_shop_display()
