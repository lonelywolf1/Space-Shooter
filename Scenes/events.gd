extends Node

signal shoot
signal respawn_player
signal shake_camera
signal blast

func timer(secs):
	return get_tree().create_timer(secs).timeout
