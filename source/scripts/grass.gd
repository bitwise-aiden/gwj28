class_name Grass
extends TileMap

func _ready() -> void:
	for cell in self.get_used_cells():
		if randf() > 0.7: 
			self.set_cellv( cell, randi() % 4 + 2 )
		else:
			self.set_cellv( cell, 1 )
