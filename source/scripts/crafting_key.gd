extends AnimatedSprite


func _ready():
	Event.connect( "show_inventory_keys", self, "show_inventory_keys" )
	Event.connect( "tutorial_advanced", self, "tutorial_advanced")


func should_show() -> bool: 
	return (
		Globals.ui.inventory.focused_crafting_area == self.get_parent() && 
		self.get_parent().items.size() > 0
	)


func show_inventory_keys( show: bool ) -> void:
	show = show && self.should_show()
	
	if Globals.tutorial_current_stage == 8:
		self.visible = show
	elif Globals.tutorial_current_stage < 14:
		self.visible = false
	else:
		self.visible = show


func tutorial_advanced( stage: int ) -> void:
	self.visible = stage == 8 && self.should_show()
