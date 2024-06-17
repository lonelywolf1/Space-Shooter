extends CharacterBody2D

var keyboard_input_x
var keyboard_input_y
var speed := randi_range(7,10)
const asteroid_speed = 50

var functions = Functions.new()
var isControlled := false
var index := 0

@export var expolode_sounds:Array[AudioStream]
@onready var sprite_2d = $Sprite2D
@onready var shot_signal = $ShotSignal
@onready var particles = $FloatParticles
@onready var collision = $ShotSignal/CollisionPolygon2D2

func _ready():
	pass

func _process(delta):
	if not isControlled:
		var direction = Vector2.UP.rotated(rotation)
		position += speed * direction
	else:
		keyboard_input_x = Input.get_axis("ui_left", "ui_right")
		keyboard_input_y = Input.get_axis("ui_up", "ui_down")
		var p_direction = Vector2(keyboard_input_x, keyboard_input_y).normalized() #getting Axis direction & normalizing to pixel moving
		velocity += p_direction * asteroid_speed
	
		move_and_slide()
		apply_friction_onplayer()
		
func _on_visible_on_screen_notifier_2d_screen_exited():
	done()

func done():
	if not isControlled and has_node("CollisionPolygon2D"):
		functions.kill_shot(self, $Sprite2D, $CollisionPolygon2D, $FloatParticles)


func apply_friction_onplayer():
	velocity *= 0.96

func _on_shot_signal_area_entered(area):
	if area.is_in_group("EnemyShot"):
		area.done()
	elif area.is_in_group("asteroid"):
		Events.destroy_asteroid_controlled.emit()
		
		if has_node("CollisionPolygon2D"):
			functions.kill_shot(self, $Sprite2D, $CollisionPolygon2D, $FloatParticles)
	elif area.is_in_group("boss"):
		Events.hurt_boss.emit()
		Events.destroy_asteroid_controlled.emit()
		
	Events.blast.emit(area.global_position)
	functions.playSounds(index, $ShotExpolsion, expolode_sounds)
