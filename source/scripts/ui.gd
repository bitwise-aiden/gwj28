extends Control

onready var inventory = $inventory
onready var crafting_menu = $crafting_menu
onready var popularity_score = $popularity_scorer


func _ready() -> void:
	Globals.ui = self
