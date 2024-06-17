extends Node

signal shoot
signal respawn_player
signal shake_camera
signal blast

var player
var enemies_left = 0

func timer(secs):
	return get_tree().create_timer(secs).timeout