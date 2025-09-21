class_name TypingChallenge extends Node3D

signal completed(node: TypingChallenge)
signal failed(node: TypingChallenge)

@export var display:Label3D # Might want to use something other than Label3D later.
@export var display_user:Label3D
@export var text_to_enter:String # Probably will set this procedurally, but leaving this option for hand-crafted levels.

var enabled:bool = false
var character_index:int = 0

@onready var displays: Node3D = %Displays

func center_displays() -> void:
	# FIXME
	# Center the text
	# This needs to be entirely refactored.
	# I think we'll have to set the position in process() in order to work when
	# the player moves. This setup is only good for this minimum viable prototype.
	var offset:float = display.text.length() * display.font_size * display.pixel_size # HACK this is only barely approximate
	displays.position.x -= offset
	#print_debug("Offset display by %s" % [offset])
	
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
				display_user.text += must_match
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
	display_user.text = ""
	center_displays()
	
func destroy() -> void:
	# Some sort of visual effect
	queue_free()
