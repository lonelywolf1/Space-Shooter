extends Button

@onready var animation_player = $AnimationPlayer

func _ready():
	#if OS.get_name() in ["Windows", "Linux", "OSX"]:
		#hide()
		
	button_down.connect(is_button_down)
	button_up.connect(is_button_up)
	
func is_button_down():
	Input.action_press("ui_accept")
	animation_player.play("shoot")
	
func is_button_up():
	Input.action_release("ui_accept")
	animation_player.play("RESET")
