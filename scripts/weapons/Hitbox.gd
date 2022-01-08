extends Area2D
class_name Hitbox

signal damage()

export (NodePath) var entity_path = ".."
onready var entity = get_node(entity_path)

#func _on_Hitbox_area_entered(area):
#	if area is DamageArea:
#		get_node("..").damage(10)
#		get_node("..").jump()
#	elif area is ArrowPoints:
#		get_node("..").absorb_energy()

#func check_energy_limit():
#	if get_node("..").stored_energy < 3:
#		return true
#	else:
#		return false

func _on_Hitbox_area_entered(area):
	emit_signal("damage", 1)

