extends Control

var networkThread
var socket

# Called when the node enters the scene tree for the first time.
func _ready():
	createNetworkThread()
	pass

func createNetworkThread():
	networkThread=Thread.new()
	networkThread.start(self, "_thread_network_function", "networkThread")

func _thread_network_function(userdata):
	var done=false
	socket = PacketPeerUDP.new()
	if (socket.listen(4000,global.ipAddress) != OK):
		print("An error occurred listening on port 4000")
		done = true;
	else:
		print("Listening on port 4000 on "+global.ipAddress)
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
	var root=get_tree().get_root()
	var myself=root.get_child(1)
	print (root,myself)
	root.remove_child(myself)
	root.add_child(global.controlOptionsNode)

func _on_ButtonTestReseau_pressed():
	print ("sending UDP test data to "+global.ipAddress+" port 4242")
	socket.set_dest_address(global.ipAddress, 4242)
	socket.put_packet("lalala".to_ascii())
