extends Spatial


var myMeshRessource
var SpatialNode

# Images
var billetImages = [
	"res://images/billets/10.jpg",
	"res://images/billets/20.jpg",
	"res://images/billets/30.jpg",
	"res://images/billets/40.jpg",
	"res://images/billets/50.jpg",
	"res://images/billets/60.jpg",
	"res://images/billets/70.jpg",
	"res://images/billets/80.jpg",
	"res://images/billets/90.jpg"]

var casinoImages = [
	"res://images/casinos/1.jpg",
	"res://images/casinos/2.jpg",
	"res://images/casinos/3.jpg",
	"res://images/casinos/4.jpg",
	"res://images/casinos/5.jpg",
	"res://images/casinos/6.jpg"]
	
var desImages = [
	["res://images/des/1W.jpg","res://images/des/2W.jpg","res://images/des/3W.jpg","res://images/des/4W.jpg","res://images/des/5W.jpg","res://images/des/6W.jpg"],
	["res://images/des/1B.jpg","res://images/des/2B.jpg","res://images/des/3B.jpg","res://images/des/4B.jpg","res://images/des/5B.jpg","res://images/des/6B.jpg"],
	["res://images/des/1G.jpg","res://images/des/2G.jpg","res://images/des/3G.jpg","res://images/des/4G.jpg","res://images/des/5G.jpg","res://images/des/6G.jpg"],
	["res://images/des/1N.jpg","res://images/des/2N.jpg","res://images/des/3N.jpg","res://images/des/4N.jpg","res://images/des/5N.jpg","res://images/des/6N.jpg"],
	["res://images/des/1Y.jpg","res://images/des/2Y.jpg","res://images/des/3Y.jpg","res://images/des/4Y.jpg","res://images/des/5Y.jpg","res://images/des/6Y.jpg"],
	["res://images/des/1R.jpg","res://images/des/2R.jpg","res://images/des/3R.jpg","res://images/des/4R.jpg","res://images/des/5R.jpg","res://images/des/6R.jpg"]
]

var imageDe = "res://images/des/1W"

# Répartition des dés des joueurs
var repartition = [null,null,null,null,null,null]

# Les noeuds des casinos 
var casinoNode = [null,null,null,null,null,null]

var billets_casinos = [
	[],
	[],
	[],
	[],
	[],
	[]]

var des_casinos = [
	[],
	[],
	[],
	[],
	[],
	[],
]

# Le noeud des dés
var deNode = null
# Quantité totale d'argent du joueur

func _ready():
	# Le noeud vers spatial (C6)
	SpatialNode = get_tree().get_root().get_node("ControlGame").get_node("Spatial")
	# Pointeur vers l'instance future de la classe MyMesh (C6)
	myMeshRessource = load("res://MyMesh.gd")
	
	# Créer dynamiquement les noeuds des casios en fils de ce noeud là (C5)
	for i in range(6):
		var posz = poscasinos(i)
		casinoNode[i] = createCasino(0,0,posz,casinoImages[i])
#	deNode = createDes(imageDe)
	var argentTotal = 0

# Fonction créant une nouvelle instance casino
# Positions de la carte, image du casino, numéro du casino
func createCasino(posx,posy,posz,imgName):
	#Créer un pointeur vers la nouvelle instance qu'on vient veut créer 
	var mi = myMeshRessource.new()
	
	# Positioner le casino au bon endroit
	mi.set_translation(Vector3(posx,posy,posz))
	
	# Récupérer le maillage de l'objet
	var meshObj = load("res://carteCasino.obj")
	mi.mesh = meshObj
	
	# Associer une surface à la carte
	var surface_material = SpatialMaterial.new()
	mi.set_surface_material(0,surface_material)
	
	# Associer la texture 
	var texture = ImageTexture.new()
	texture.load(imgName)
	surface_material.albedo_texture = texture
	
	# Ajouter le casino en tant que child
	SpatialNode.add_child(mi)
	return mi

func createBillet(posx,posy,posz,nombre):
	#Créer un pointeur vers la nouvelle instance qu'on vient veut créer 
	var mi = myMeshRessource.new()
	
	# Positioner le casino au bon endroit
	mi.set_translation(Vector3(posx,posy,posz))
	
	# Récupérer le maillage de l'objet
	var meshObj = load("res://carteCasino.obj")
	mi.mesh = meshObj
	
	# Associer une surface à la carte
	var surface_material = SpatialMaterial.new()
	mi.set_surface_material(0,surface_material)
	
	# Associer la texture 
	var texture = ImageTexture.new()
	texture.load(billetImages[nombre])
	surface_material.albedo_texture = texture
	
	# Ajouter le casino en tant que child
	SpatialNode.add_child(mi)
	return mi

func poscasinos(num):
	return 10*num-30	
	
func add_billet_cas(num, billet):
	print("ajouter le billet "+String(billet)+" au casino "+String(num))
	var posx = 3
	var posy = 0
	var posz = poscasinos(num)+billets_casinos[num].size()*2
	billets_casinos[num].append(createBillet(posx,posy,posz,billet))
	billets_casinos[num][billets_casinos[num].size()-1].set_rotation(Vector3(0,PI/2,0))
	

func add_des_cas(joueur, des, casino):
	for d in range(des):
		print("Ajouter %d dés au casino %d pour le joueur %d"%[des,casino,joueur])
		var posx = -3-des_casinos[casino].size()*8
		var posy = 0
		var posz = poscasinos(casino)
		des_casinos[casino].append(createDe(posx,posy,posz,joueur,casino))
		
func createDe(posx,posy,posz,couleur,nombre):
	#Créer un pointeur vers la nouvelle instance qu'on vient veut créer 
	var mi = myMeshRessource.new()
	
	# Positioner le dé au bon endroit
	mi.set_translation(Vector3(posx,posy,posz))
	
	# Récupérer le maillage de l'objet
	var meshObj = load("res://carteCasino.obj")
	mi.mesh = meshObj
	
	# Associer une surface au dé
	var surface_material = SpatialMaterial.new()
	mi.set_surface_material(0,surface_material)
	
	# Associer la texture 
	var texture = ImageTexture.new()
	texture.load(desImages[couleur][nombre])
	surface_material.albedo_texture = texture
	
	# Ajouter le dé en tant que child
	SpatialNode.add_child(mi)
	return mi
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

