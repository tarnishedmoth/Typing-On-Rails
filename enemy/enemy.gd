class_name Enemy extends Node3D

@export var typing_challenges:Array[TypingChallenge]
var current_challenge:TypingChallenge

@export var max_failures:int = 2

@export var damage_range:Vector2i = Vector2i(1, 5) ## Min and max damage dealt.

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

var failures:int = 0

var _level:Level

@onready var start_position:Vector3 = position

func _enter_tree() -> void:
	SignalBus.level_started.connect(start)

func _ready() -> void:
	# Connect typing capture nodes
	for challenge in typing_challenges:
		challenge.completed.connect(_on_challenge_completed)
	
	# Set up timer
	move_timer = Timer.new()
	add_child(move_timer)
	move_timer.timeout.connect(move_timer_timeout)
	
func start(level:Level) -> void:
	_level = level
	move_to(move_points.front())
	await move_tween.finished
	next_typing_challenge()
	
func next_typing_challenge() -> void:
	current_challenge = typing_challenges.pop_front()
	if current_challenge == null:
		die()
	else:
		current_challenge.reset()
		current_challenge.enable_input()
		
func die() -> void:
	# Foo
	queue_free()
	
func deal_damage(amount:int) -> void:
	SignalBus.enemy_dealt_damage.emit(amount, self)

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


func _on_challenge_completed(challenge:TypingChallenge) -> void:
	challenge.destroy()
	next_typing_challenge()

func _on_challenge_failed(challenge:TypingChallenge) -> void:
	failures += 1
	
	deal_damage(randi_range(damage_range.x, damage_range.y))
	
	if not failures > max_failures:
		challenge.reset()
	else:
		next_typing_challenge()
