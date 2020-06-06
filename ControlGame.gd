extends Control

var SpatialNode
var id
var score

func _ready():
	id = -1
	score = 0
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
			SpatialNode.add_billet_cas(int(mess[1]),int(mess[2])-1)
			
		'T': # A mon tour, je lance les dés
			var des =lancer_des()
			get_tree().get_root().get_node("ControlGame").get_node("ItemList").clear()
			
		'D': #Ajouter des dés à un casino
			SpatialNode.add_des_cas(int(mess[1]),int(mess[2]),int(mess[3]))
			pass
			
		'R': #Récupérer un billet
			SpatialNode.recup_billet(int(mess[1])-1)
			score = score + (int(mess[1]))*10000
			get_tree().get_root().get_node("ControlGame").get_node("Score").set_text("Score : %d"%score)
			
		'M': # Nouvelle manche
			SpatialNode.nouvelle_manche()
			SpatialNode.creer_des(id)
			
		'I' : # Set id
			if id == -1:
				id = int(mess[1])
		'F': # 
			var msg
			if int(mess[1]):
				 msg = "Score : %d VOUS AVEZ GAGNÉ "%score
			else :
				msg = "Score : %d VOUS AVEZ PERDU "%score
			get_tree().get_root().get_node("ControlGame").get_node("Score").set_text(msg)

func _on_ButtonMenu_pressed():
	var root=get_tree().get_root()
	var myself=root.get_child(1)
	print (root,myself)
	root.remove_child(myself)
	root.add_child(global.controlMenuNode)

func lancer_des():
	# Tirer les dés
	var des = [0,0,0,0,0,0]
	var nb_d = SpatialNode.des_joueur.size()
	
#	print("Tirer %d dés"%nb_d)
	for i in range(nb_d):
		des[randi()%6] += 1
	var imax = 0
	
	var non_nuls =[]
	for i in range(des.size()):
		if des[i] > 0 :
			non_nuls.append(i+1)
	
	SpatialNode.afficher_des(des)
	
	var de_choisi = _on_ItemList_item_selected(des)-1
	
	
	SpatialNode.remove_des(des,de_choisi)
	global.controlMenuNode.socket.put_packet(("P %d %d %d"%[id,des[de_choisi],de_choisi]).to_ascii())

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
	for i in range(6):
		if des[i]!=0:
			itemlist.add_item(str(i+1))
	
	# On attend
	while(itemlist.is_anything_selected ( )==false):
		pass
	
	var ItemNo = itemlist.get_selected_items()
	
	var mon_des=int(itemlist.get_item_text(ItemNo[0]))
	return mon_des
	

