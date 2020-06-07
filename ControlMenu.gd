extends Control

var networkThread
var socket
var PORT = 4000

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func createNetworkThread():
	networkThread=Thread.new()
	networkThread.start(self, "_thread_network_function", "networkThread")

func _thread_network_function(_userdata):
	var done=false
	socket = PacketPeerUDP.new()
	if (socket.listen(PORT,global.ipAddress) != OK):
		print("An error occurred listening on port %d"%PORT)
		done = true;
	else:
		print("Listening on port %d on "%PORT+global.ipAddress)
	while (done!=true):
		if(socket.get_available_packet_count() > 0):
			var data = socket.get_packet().get_string_from_ascii()
			print("Data received: " + data)
			# Fonction s'occupant de la gestion des messages reçus
			global.controlGameNode._networkMessage(data)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_ButtonJouer_pressed():
	
	var root=get_tree().get_root()
	var myself=root.get_child(1)
	print (root,myself)
	root.remove_child(myself)
	root.add_child(global.controlGameNode)
	
	var connectMessage="C"+str(global.direction)
	socket.set_dest_address(global.ipAddress, 4242)
	socket.put_packet(connectMessage.to_ascii())

func _on_ButtonOptions_pressed():
	var le = get_tree().get_root().get_node("ControlMenu").get_node("PortNumber").get_line_edit()
	PORT = int(le.text)
	createNetworkThread()
	
#	var rootc=get_tree().get_root().get_node("ControlMenu")
#	rootc.get_node("PortNumber").set_disable_input(true)
#	rootc.get_node("ButtonOption").set_disable_input(true)
#	rootc.get_node("ButtonTestReseau").set_disable_input(false)
#	rootc.get_node("ButtonJouer").disable = false


func _on_ButtonTestReseau_pressed():
	print ("sending UDP test data to "+global.ipAddress+" port 4242")
	socket.set_dest_address(global.ipAddress, 4242)
	socket.put_packet("lalala".to_ascii())
