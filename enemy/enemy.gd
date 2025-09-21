class_name Enemy extends Node3D

## How quickly the tween moves this node to the next position.
@export var move_duration:float = 1.25

## How long to wait in place before [method move_to_next] is called.
@export var wait_duration:float = 2.0

## An array of [Vector3] positions relative to the starting [member global_position] of this node.
@export var move_points:Array[Vector3] = [Vector3.ZERO, Vector3.UP]

## Internal counter for cycling through [member move_points].
var move_point_index:int = 0

var move_tween:Tween
var move_timer:Timer

var _level:Level

@onready var start_position:Vector3 = position

func _enter_tree() -> void:
	SignalBus.level_started.connect(start)

func _ready() -> void:
	move_timer = Timer.new()
	add_child(move_timer)
	move_timer.timeout.connect(move_timer_timeout)
	
func start(level:Level) -> void:
	_level = level
	move_to(move_points.front())

## Uses the [member move_tween] to move the [member position] to the next [Vector3] in the [member move_points] array.
func move_to(point:Vector3, duration:float = move_duration) -> void:
	check_kill_tween(move_tween)
	move_tween = create_tween()
	move_tween.set_trans(Tween.TRANS_CUBIC)
	move_tween.tween_property(self, ^"position", start_position+point, duration)
	move_tween.tween_callback(move_timer.start.bind(wait_duration))
	
func move_to_next() -> void:
	move_point_index += 1
	if move_point_index >= move_points.size():
		move_point_index = 0
	
	move_to(move_points[move_point_index], move_duration)
	
func check_kill_tween(tween:Tween) -> void:
	if tween:
		if tween.is_running():
			tween.kill()
	
func move_timer_timeout() -> void:
	move_to_next()
