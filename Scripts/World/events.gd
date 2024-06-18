extends Node

signal shoot
signal respawn_player
signal shake_camera
signal blast
signal destroy_asteroid_controlled
signal hurt_boss
signal end_game
signal blast_boss
signal kill_player

var player
var enemies_left = 0
var TOTAL_PLAYER_HEALTH := 3
var controlling_asteroid := false

func timer(secs):
	return get_tree().create_timer(secs).timeout
