extends Node

@export var player:Player
@onready var sprite_2d = $Sprite2D
@onready var timer_text = $TimerText

var time = 0

func _ready():
	make_visible(false)
	update_text(0)
	
	Events.connect("control_asteroid", func(state:bool):
		if not state:
			make_visible(state)
			time = 0
			return
			
		time = 5
		count_down(time)
		)
	
	
func update_text(amount:int):
	timer_text.text = str(amount) + "s"

func count_down(amount:int):
	make_visible(true)
	update_text(amount)
	for i in amount:
		if time > 0:
			await Events.timer(1)
			time-=1
			update_text(amount-(i+1))
			
	make_visible(false)
		
func make_visible(state:bool):
	sprite_2d.visible = state
	
	if state:
		timer_text.show()
	else:
		timer_text.hide()
