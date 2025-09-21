class_name HUD extends Control

@onready var ready_to_play_label: Label = %ReadyToPlayLabel
@onready var score: LabelWithValue = %Score
@onready var health: LabelWithValue = %Health


func _enter_tree() -> void:
	SignalBus.level_ready.connect(_on_level_ready.unbind(1))
	SignalBus.player_ready_to_play.connect(_on_player_ready_to_play.unbind(1))
	
	SignalBus.health_changed.connect(_on_health_changed)
	SignalBus.score_changed.connect(_on_score_changed)
	
func _on_health_changed(amount:int) -> void:
	health.update(str(amount))
	
func _on_score_changed(amount:int) -> void:
	score.update(str(amount))

func _on_level_ready() -> void:
	ready_to_play_label.show()

func _on_player_ready_to_play() -> void:
	ready_to_play_label.hide()
