class_name Level extends Node3D

var started:bool = false
var _player:Player
var score:int

func _enter_tree() -> void:
	SignalBus.player_ready_to_play.connect(start)
	SignalBus.enemy_killed.connect(_on_enemy_killed)
	
func _ready() -> void:
	SignalBus.level_ready.emit(self)
	print("Level ready.")

func start(player:Player) -> void:
	_player = player
	started = true
	SignalBus.level_started.emit(self)
	
	print("Level starting.")
	# Foo

func _on_enemy_killed(_enemy: Enemy, score_awarded: int) -> void:
	score += score_awarded
	SignalBus.score_changed.emit(score)
