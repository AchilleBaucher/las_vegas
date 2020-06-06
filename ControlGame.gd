extends Control

var SpatialNode
var id

func _ready():
	id = -1
	SpatialNode = get_tree().get_root().get_node("ControlGame").get_node("Spatial")
	#get_tree().get_root().get_node("ControlGame").get_node("Spatial").get_node("TextEdit").remove_child() 
	#get_tree().get_root().get_node("ControlGame").get_node("Spatial").get_node("ItemList").hide()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _networkMessage(mess):
	print ("_networkMessage=",mess)
	match mess[0]:
		'B': # Ajouter un billet à un casino
			SpatialNode.add_billet_cas(int(mess[1]),int(mess[2]))
			
		'T': # A mon tour, je lance les dés
			var des =lancer_des()
			_on_ItemList_item_selected(des)
			
		'D': #Ajouter des dés à un casino
			SpatialNode.add_des_cas(int(mess[1]),int(mess[2]),int(mess[3]))
			pass
			
		'R': #Récupérer un billet
			Spatial.recup_billet_cas(int(mess[1]),int(mess[2]))
		'S':
			pass
		'I' : # Set id
			if id == -1:
				id = int(mess[1])
				SpatialNode.creer_des(id)

func _on_ButtonMenu_pressed():
	var root=get_tree().get_root()
	var myself=root.get_child(1)
	print (root,myself)
	root.remove_child(myself)
	root.add_child(global.controlMenuNode)

func lancer_des():
	# Tirer les dés
	var des = [0,0,0,0,0,0]
	var nb_d = 6 #SpatialNode.des_joueur.size()
	
	print("Tirer %d dés"%nb_d)
	for i in range(nb_d):
		des[randi()%6] += 1
	var imax = 0
	for i in range(des.size()):
		if des[i] > des[imax] :
			imax = i
			
	SpatialNode.afficher_des(des)
	SpatialNode.remove_des(des,imax)
	
	return des
	######Recuperer le choix du joueur####
	
	# Pour l'instant envoyer au pif, changer bientot !#
#	print ("sending UDP test data to "+global.ipAddress+" port 4242")
	#global.controlMenuNode.socket.put_packet(("P %d %d %d"%[id,des[imax],imax]).to_ascii())


func createTile(x,y,tilenum):
	# Create a new tile instance
	var mi=MeshInstance.new()
	# and translate it to its final position
	mi.set_translation(Vector3(x,0,y))
	# load the tile mesh
	var meshObj=load("res://obj/tile00.obj")
	# and assign the mesh instance with it
	mi.mesh=meshObj
	# create a new spatial material for the tile
	var surface_material=SpatialMaterial.new()
	# and assign the material to the mesh instance
	mi.set_surface_material(0,surface_material)
	# create a new image texture that will be used as a tile texture
	var texture=ImageTexture.new()
	#texture.load(tileNames[tilenum])
	# and perform the assignment to the surface_material
	surface_material.albedo_texture=texture
	# add the newly created instance as a child of the Origine3D Node
	$Spatial.add_child(mi)
	return mi
	
func createExplorer(x,y,num):
	# Create a new tile instance
	var mi=MeshInstance.new()
	# and translate it to its final position
	mi.set_translation(Vector3(x,0,y))
	mi.set_rotation(Vector3(0,PI/2.0,0))
	mi.set_scale(Vector3(0.5,0.5,0.5))
	# load the tile mesh
	var meshObj=load("res://obj/indiana02.obj")
	# and assign the mesh instance with it
	mi.mesh=meshObj
	# create a new spatial material for the tile
	var surface_material=SpatialMaterial.new()
	# set its color
	#surface_material.albedo_color=explorerColor[num]
	# and assign the material to the mesh instance
	mi.set_surface_material(0,surface_material)
	# add the newly created instance as a child of the Origine3D Node
	$Spatial.add_child(mi)
	return mi



func _on_ItemList_item_selected(des):
	var itemlist=get_tree().get_root().get_node("ControlGame").get_node("ItemList")
	for i in range(len(des)):
		if des[i]!=0:
			itemlist.add_item(str(i))
	while(itemlist.is_anything_selected ( )==false):
		pass
	var ItemNo = itemlist.get_selected_items()
	var mon_des=itemlist.get_item_text(ItemNo[0])
	global.controlMenuNode.socket.put_packet(("P %d %d %d"%[id,des[mon_des],mon_des]).to_ascii())
	print(mon_des)
	

