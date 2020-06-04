extends MeshInstance

class_name MyMesh, "res://icon.png"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
#
#func _setEndPosition(v):
#	pStart=get_translation()
#	pEnd=v
#	pMiddle=Vector3((pStart.x+pEnd.x)/2.0,5.0,(pStart.z+pEnd.z)/2.0)
#	aStart=get_rotation()
#
#func _moveFromToFlip(lt):
#	var q0=pStart.linear_interpolate(pMiddle,lt)
#	var q1=q0.linear_interpolate(pEnd,lt)
#	set_translation(q1)
#	set_rotation(Vector3(0,0,aStart.z).linear_interpolate(Vector3(0,0,aStart.z-PI), lt))
#
#func _moveFromTo(lt):
#	var q0=pStart.linear_interpolate(pMiddle,lt)
#	var q1=q0.linear_interpolate(pEnd,lt)
#	set_translation(q1)
