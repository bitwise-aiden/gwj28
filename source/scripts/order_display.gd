extends Node

export( Dictionary ) var textures = {}

onready var items = $order_items.get_children()

var order = null


func _ready() -> void:
	self.add_to_group( "order_area" )
	self.visible = false


func _process( delta ) -> void:
	if self.order:
		$waiting_progress.value = self.order.waiting_progress()


func fulfill_order( item: Resource ) -> void:
	self.order.fulfill_order( item )


func is_waiting() -> bool:
	return self.order != null
	

func set_order( order = null ) -> void:
	self.order = order
	self.visible = !!order
	
	self.update_display()


func update_display() -> void:
	if !self.order:
		return
	
	for i in self.items.size():
		var item_name = "Blank"
		
		if i < self.order.size():
			item_name = self.order.name_at( i )
		
		self.items[ i ].texture = self.textures[ item_name ]
	
	$order_color.modulate = self.order.color
