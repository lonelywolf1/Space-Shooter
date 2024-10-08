extends Button

@onready var animation_player = $AnimationPlayer

var can_use := false
@export var use_cool_down := 1

func _ready():
	#if OS.get_name() in ["Windows", "Linux", "OSX"]:
		#hide()
		
	animation_player.play("no_use")
	can_use = false
	
	#Events
	Events.boss_dead.connect(func():
		animation_player.play("no_use")
		can_use = false
		)
	Events.boss_spawn.connect(func():
		animation_player.play("in_use")
		can_use = true
		)
	Events.control_asteroid.connect(func(state):
		if !state:
			can_use = false
			await Events.timer(use_cool_down)
			can_use = true
			animation_player.play("in_use")
		else:
			animation_player.play("shoot")
			animation_player.queue("no_use")
		)
		
	button_down.connect(control_asteroid_down)
	button_up.connect(control_asteroid_up)
	
func control_asteroid_down():
		animation_player.play("shoot")
		Input.action_press("Interaction")
		can_use = false
		
func control_asteroid_up():
		animation_player.play("no_use")
		Input.action_release("Interaction")
		can_use = false
