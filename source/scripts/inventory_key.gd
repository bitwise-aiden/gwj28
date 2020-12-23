extends AnimatedSprite


func _ready():
	Event.connect( "show_inventory_keys", self, "show_inventory_keys" )
	Event.connect( "tutorial_advanced", self, "tutorial_advanced")


func should_show() -> bool:
	if !self.get_parent().has_item:
		return false
	
	if Globals.ui.inventory.focused_crafting_area && self.get_parent().is_craftable:
		return true
		
	if Globals.ui.inventory.focused_order_area && !self.get_parent().is_craftable:
		return true
		
	return false


func show_inventory_keys( show: bool ) -> void:
	show = show && self.should_show()
	
	if Globals.tutorial_current_stage in [ 7, 13 ] and self.animation == "1":
		self.visible = show
	elif Globals.tutorial_current_stage < 14:
		self.visible = false
	else:
		self.visible = show


func tutorial_advanced( stage: int ) -> void:
	self.visible = stage in [ 7, 13 ]
