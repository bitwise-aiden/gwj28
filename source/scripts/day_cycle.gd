extends Node

const FULL_TIME = 90.0
const DAY_PERCENT = 0.666

var time = 0.0


func _process( delta: float ) -> void:
	self.time += delta


func day_number() -> float: 
	return floor( self.time / self.FULL_TIME )


func time_of_day() -> float: 
	return (self.time / self.FULL_TIME - self.day_number()) * self.FULL_TIME


func is_day() -> bool: 
	return self.time_of_day() <= self.FULL_TIME * self.DAY_PERCENT


func is_day_in( offset_time: float ) -> bool:
	return self.time_of_day() + offset_time <= self.FULL_TIME * self.DAY_PERCENT
