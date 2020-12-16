class_name PopularityScorer
extends Node


var popularity: int = 0


func _ready() -> void:
	InstanceManager.popularity_scorer = self
	
	Event.connect( "order_fulfilled", self, "adjust_popularity" )


func adjust_popularity( amount: int ) -> void:
	self.popularity += amount
	$popularity.text = "Popularity: %d" % [ self.popularity ]
