class_name Player extends Node3D

signal health_changed(new_health:int)

@export var health:int = 100
@export var travel_speed:float = 5.0

## This value is assigned in [method _on_level_ready].
var _current_level:Level

func _on_level_ready(level:Level) -> void:
	_current_level = level


func _enter_tree() -> void:
	SignalBus.level_ready.connect(_on_level_ready)
	
func _unhandled_input(event: InputEvent) -> void:
	if _current_level:
		# Level is loaded and ready.
		if not _current_level.started:
			# Waiting for player to start the game.
			if event.is_action_released(&"ReadyToPlay"):
				SignalBus.player_ready_to_play.emit(self)
	
func take_damage(amount:int) -> void:
	health = maxi(0, health-amount)
	
	health_changed.emit(health)
	
	if health == 0:
		die()
	
func die() -> void:
	print("Player died.")

func _on_enemy_dealt_damage(amount:int, _enemy:Enemy) -> void:
	take_damage(amount)
