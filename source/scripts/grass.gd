class_name Grass
extends TileMap

const SIZE = 200

func _ready() -> void:
	var half_size = self.SIZE / 2
	
	for x in range( -half_size, half_size ):
		for y in range( -half_size, half_size ):
			if randf() > 0.7:
				self.set_cell( x , y, randi() % 4 + 2 )
			else: 
				self.set_cell( x, y, 1 )
