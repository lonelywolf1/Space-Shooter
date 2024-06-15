extends Node

signal shoot
signal respawn_player
signal shake_camera

func timer(secs):
	return get_tree().create_timer(secs).timeout
