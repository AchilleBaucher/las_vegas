extends Spatial


var myMeshRessource
var SpatialNode

# Images
var billetImages = ["res://images/billets/50.jpg"]
var casinoImages = ["res://images/casinos/1.jpg"]
var imageDe = "res://images/des/de"

# Répartition des dés des joueurs
var repartition = [null,null,null,null,null,null]

# Les noeuds des casinos 
var casinoNode = [null,null,null,null,null,null]

# Le noeud des dés
var deNode = null
# Quantité totale d'argent du joueur

func _ready():
	# Le noeud vers spatial (C6)
	SpatialNode = get_tree().get_root().get_node("ControlGame").get_node("Spatial")
	# Pointeur vers l'instance future de la classe MyMesh (C6)
	myMeshRessource = load("res://MyMesh.gd")
	
	# Créer dynamiquement les noeuds des casios en fils de ce noeud là (C5)
	casinoNode[0] = createCasino(5,5,5,1,casinoImages[0])
	var billet1 = createBillet(4,4,4,1,billetImages[0])
	
	casinoNode[0] = createCasino(5,10,5,2,casinoImages[0])
	casinoNode[0] = createCasino(3,2,1,3,casinoImages[0])
	casinoNode[0] = createCasino(4,5,8,4,casinoImages[0])
#	deNode = createDes(imageDe)
	var argentTotal = 0

# Fonction créant une nouvelle instance casino
# Positions de la carte, image du casino, numéro du casino
func createCasino(posx,posy,posz,numero,imgName):
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

func createBillet(posx,posy,posz,nombre,imgName):
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
	
func createDes(couleur):
	#Créer un pointeur vers la nouvelle instance qu'on vient veut créer 
	var mi = myMeshRessource.new()
	
	# Positioner le dé au bon endroit
	mi.set_translation(Vector3(0,0,0))
	
	# Récupérer le maillage de l'objet
	var meshObj = load("res://des.obj")
	mi.mesh = meshObj
	
	# Associer une surface au dé
	var surface_material = SpatialMaterial.new()
	mi.set_surface_material(0,surface_material)
	
	# Associer la texture 
	var texture = ImageTexture.new()
	texture.load(couleur)
	surface_material.albedo_texture = texture
	
	# Ajouter le dé en tant que child
	SpatialNode.add_child(mi)
	return mi
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

