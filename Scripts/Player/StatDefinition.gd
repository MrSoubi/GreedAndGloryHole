class_name StatDefinition
extends Resource

@export var base_value : float
var additive: float = 0.0
var multiplier: float = 1.0

var current_value: float:
	get:
		return (base_value + additive) * multiplier
