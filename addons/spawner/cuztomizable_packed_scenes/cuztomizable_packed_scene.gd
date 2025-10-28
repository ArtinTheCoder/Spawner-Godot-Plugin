@tool
@icon("res://addons/spawner/cuztomizable_packed_scenes/customizable-packed-scene.png")
extends Resource
class_name CustomizablePackedScene

@export var scene: PackedScene:
	set(value):
		scene = value
		overrides = {}
		notify_property_list_changed()

var overrides: Dictionary = {}

func _get(property):
	if scene != null:
		if property in overrides:
			return overrides[property]
		elif scene.instantiate().get_script().get_property_default_value(property) != null:
			return scene.instantiate().get(property)

func _set(property, value):
	if scene != null:
		overrides[property] = value

func _get_property_list():
	if scene != null:
		return (
			scene.instantiate().get_script().get_script_property_list()
				.filter(func(property): return property["usage"] & PROPERTY_USAGE_EDITOR != 0 and \
												property["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE)
		)
	else:
		return []

func _property_can_revert(property):
	return property in overrides

func _property_get_revert(property):
	if property in overrides:
		return scene.instantiate().get(property)
	else:
		return null

func instantiate() -> Node:
	var node = scene.instantiate()
	
	for property in overrides:
		node.set(property, overrides[property])
	
	return node
