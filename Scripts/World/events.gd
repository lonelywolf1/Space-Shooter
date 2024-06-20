extends Node

signal shoot
signal respawn_player
signal shake_camera
signal blast
signal destroy_asteroid_controlled
signal control_asteroid
signal hurt_boss
signal boss_dead
signal boss_spawn
signal blast_boss
signal kill_player
signal next_round
signal shoot_touch

var player
var enemies_left = 0
var TOTAL_PLAYER_HEALTH := 3
var controlling_asteroid := false
var round_updated = false

func timer(secs):
	return get_tree().create_timer(secs).timeout
	
func _process(delta):
	if enemies_left == 0 and not round_updated:
		next_round.emit()
		round_updated = true
