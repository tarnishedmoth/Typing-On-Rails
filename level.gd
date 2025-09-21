class_name Level extends Node3D

var started:bool = false
var _player:Player

func _enter_tree() -> void:
	SignalBus.player_ready_to_play.connect(start)
	
func _ready() -> void:
	SignalBus.level_ready.emit(self)
	print("Level ready.")

func start(player:Player) -> void:
	_player = player
	started = true
	SignalBus.level_started.emit(self)
	
	print("Level starting.")
	# Foo
