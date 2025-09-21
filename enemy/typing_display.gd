class_name TypingChallenge extends Node3D

signal completed(node: TypingChallenge)
signal failed(node: TypingChallenge)

@export var display:Label3D # Might want to use something other than Label3D later.
@export var text_to_enter:String

var enabled:bool = false
var character_index:int = 0

var _level:Level
var _player:Player

func _enter_tree() -> void:
	SignalBus.level_ready.connect(_on_level_ready)
	SignalBus.player_ready_to_play.connect(_on_player_ready_to_play)
	
func _unhandled_key_input(event: InputEvent) -> void:
	if enabled:
		if event.is_echo():
			# Ignore repeat events from holding down a key.
			return
		
		if event.is_pressed():
			var input:String = event.as_text()
			print("Raw input: %s" % [input])
			var compare:String
			
			if input.length() > 1:
				# Modifier or special key
				if input.begins_with("Shift+"):
					compare = input.right(1).to_upper()
				else:
					# Ignore the input
					return
			else:
				compare = input.to_lower()
				
			var must_match:String = text_to_enter[character_index]
			print("Compare: %s to %s" % [compare, must_match])
			
			if compare == must_match:
				# Correct character
				next_character()
			else:
				# Non matching character
				failed.emit(self)
				
				
func enable_input() -> void:
	enabled = true
	
func disable_input() -> void:
	enabled = false
	
func next_character() -> void:
	character_index += 1
	if character_index >= text_to_enter.length():
		# Success
		print("End of text challenge reached.")
		completed.emit(self)
	else:
		print("Next character: %s" % text_to_enter[character_index])
	
func reset() -> void:
	display.text = text_to_enter
	
func destroy() -> void:
	# Some sort of visual effect
	queue_free()
	
func _on_level_ready(level:Level) -> void:
	_level = level

func _on_player_ready_to_play(player:Player) -> void:
	_player = player
