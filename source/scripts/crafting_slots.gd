extends Node2D


export (Dictionary) var textures = {}

var item_slots = []


func _ready() -> void:
	for slot in self.get_children():
		self.item_slots.append( slot.get_child( 0 ))


func update_items( items ): 
	for index in range( self.item_slots.size() ):
		if index < items.size():
			self.item_slots[ index ].texture = self.textures[ items[ index ].name ]
		else:
			self.item_slots[ index ].texture = null
