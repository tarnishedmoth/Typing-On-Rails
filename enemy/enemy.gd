class_name Enemy extends Node3D

@export_group("Prerequisites")
@export var typing_challenge_scene:PackedScene ## Instantiated for each.
@export var challenges_node: Node3D

@export_group("Challenge")
@export var typing_challenges_texts:Array[String]
@export var score_multiplier: float = 2.0
var typing_challenges:Array[TypingChallenge]
var current_challenge:TypingChallenge

@export var max_failures:int = 2
@export var damage_range:Vector2i = Vector2i(1, 5) ## Min and max damage dealt.

@export_group("Movement")
## How quickly the tween moves this node to the next position.
@export var move_duration:float = 1.25

## How long to wait in place before [method move_to_next] is called.
@export var wait_duration:float = 2.0

## An array of [Vector3] positions relative to the starting [member global_position] of this node.
@export var move_points:Array[Vector3] = [Vector3.ZERO, Vector3.UP]

var enabled:bool = false

## Internal counter for cycling through [member move_points].
var move_point_index:int = 0

var move_tween:Tween
var move_timer:Timer

var alive_time:float = 0.0
var total_characters_typed:int = 0
var failures:int = 0

var _level:Level
@onready var start_position:Vector3 = position

func _enter_tree() -> void:
	if not typing_challenge_scene:
		push_error("Scene must be assigned to export property!")
		queue_free()
		return
	
	SignalBus.level_started.connect(start)
	
	for item in typing_challenges_texts:
		# Instantiate and setup a typing challenge scene prefab.
		var challenge = typing_challenge_scene.instantiate()
		challenge.text_to_enter = item
		challenges_node.add_child(challenge)
		challenge.hide()
		typing_challenges.append(challenge)

func _ready() -> void:
	# Connect typing capture nodes
	for challenge in typing_challenges:
		challenge.completed.connect(_on_challenge_completed)
		challenge.failed.connect(_on_challenge_failed)
	
	# Set up timer
	move_timer = Timer.new()
	add_child(move_timer)
	move_timer.timeout.connect(move_timer_timeout)
	
func _process(delta: float) -> void:
	if enabled:
		alive_time += delta
	
func start(level:Level) -> void:
	_level = level
	move_to(move_points.front())
	await move_tween.finished
	enabled = true
	next_typing_challenge()
	
func next_typing_challenge() -> void:
	current_challenge = typing_challenges.pop_front()
	if current_challenge == null:
		die()
	else:
		total_characters_typed += current_challenge.text_to_enter.length()
		current_challenge.reset()
		current_challenge.show()
		current_challenge.enable_input()
		
func die() -> void:
	enabled = false
	# Scoring
	var score_to_award:float = total_characters_typed / (alive_time / score_multiplier)
	SignalBus.enemy_killed.emit(self, ceili(score_to_award))
	
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

func _on_challenge_failed(_challenge:TypingChallenge) -> void:
	return
	
	# Don't think I like this idea. I want to have multiple enemies on screen
	# and the ability to type at multiple when they share characters in their text.
	
	# Count failures and deal damage each time.
	#failures += 1
	#
	#deal_damage(randi_range(damage_range.x, damage_range.y))
	#
	#if not failures > max_failures:
		#challenge.reset()
	#else:
		#next_typing_challenge()
