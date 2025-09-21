class_name SignalBusClass extends Node
@warning_ignore_start("unused_signal")

## Player
signal player_ready_to_play(player:Player)
signal player_died(player:Player)

## Level
signal level_ready(level:Level)
signal paused(toggle:bool)
signal level_started(level:Level)
signal level_completed(level:Level)
signal level_failed(level:Level)

## Metrics
signal points_changed(value:int)
signal health_changed(value:int)
signal enemy_killed(enemy:Enemy)
signal checkpoint_reached
