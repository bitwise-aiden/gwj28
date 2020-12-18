class_name PopularityScorer
extends Node


var average_stars = 0
var count_by_stars = {}
var popularity: int = 0


func _ready() -> void:
	Globals.popularity_scorer = self
	
	Event.connect( "order_fulfilled", self, "adjust_popularity" )


func adjust_popularity( amount: int ) -> void:
	if !amount in self.count_by_stars:
		self.count_by_stars[ amount ] = 0
	
	self.count_by_stars[ amount ] += 1
	
	var total_star_count = 0.0
	var total_star_value = 0.0
	self.popularity = 0
	
	for star in self.count_by_stars:
		var count = self.count_by_stars[ star ]
		
		total_star_count += count
		total_star_value += star * count
		
		self.popularity += ( star - 3 ) * count

	self.average_stars = total_star_value / total_star_count
	
	$popularity.text = "Stars: %f\nPopularity: %f\n\n debug: %s" % [
		self.average_stars,
		self.popularity,
		String( self.count_by_stars )
	]
