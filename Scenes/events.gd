extends Node

signal shoot
signal respawn_player

func timer(secs):
	return get_tree().create_timer(secs).timeout
