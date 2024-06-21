extends Node2D

@export var skins:Array[Sprite2D]

@onready var current_skin = skins.pick_random()

func _ready() -> void:
	print(skins.pick_random())
	for skin in skins:
		if skin != current_skin:
			skin.queue_free()
