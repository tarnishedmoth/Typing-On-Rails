class_name LabelWithValue extends HBoxContainer

@export var label: Label
@export var value: Label

func update(new_value: String) -> void:
	value.text = new_value
