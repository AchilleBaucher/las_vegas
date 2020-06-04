extends Camera

var nodeDialog
var coef=15.0

var pressed=[0,0]

# Called when the node enters the scene tree for the first time.
func _ready():
	nodeDialog=get_tree().get_root().get_node("ControlGame").get_node("Spatial").get_node("Dialog")
	
	print ("nodeDialog",nodeDialog)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("ui_up"):
		translation.x-=delta * coef
	if Input.is_action_pressed("ui_down"):
		translation.x+=delta * coef
	if Input.is_action_pressed("ui_right"):
		translation.z-=delta * coef
	if Input.is_action_pressed("ui_left"):
		translation.z+=delta * coef
		
#		if Input.is_joy_button_pressed(0,JOY_BUTTON_5) and pressed[0]==0:
#			pressed[0]=1
#			print ("R1 pressed")
#
#			var joystickMessage="J"+global.direction+'R'
#			global.mplayer.send_bytes(joystickMessage.to_ascii())
#		elif !Input.is_joy_button_pressed(0,JOY_BUTTON_5) and pressed[0]==1:
#			pressed[0]=0
#			print ("R1 released")
#
#		if Input.is_joy_button_pressed(0,JOY_BUTTON_4) and pressed[1]==0:
#			pressed[1]=1
#			print ("L1 pressed")
#
#			var joystickMessage="J"+global.direction+'L'
#			global.mplayer.send_bytes(joystickMessage.to_ascii())
#		elif !Input.is_joy_button_pressed(0,JOY_BUTTON_4) and pressed[1]==1:
#			pressed[1]=0
#			print ("L1 released")

#       pass
