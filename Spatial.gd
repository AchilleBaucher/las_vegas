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
	
#var desImages = [
#	["res://images/des/1W.jpg","res://images/des/2W.jpg","res://images/des/3W.jpg","res://images/des/4W.jpg","res://images/des/5W.jpg","res://images/des/6W.jpg"],
#	["res://images/des/1B.jpg","res://images/des/2B.jpg","res://images/des/3B.jpg","res://images/des/4B.jpg","res://images/des/5B.jpg","res://images/des/6B.jpg"],
#	["res://images/des/1G.jpg","res://images/des/2G.jpg","res://images/des/3G.jpg","res://images/des/4G.jpg","res://images/des/5G.jpg","res://images/des/6G.jpg"],
#	["res://images/des/1N.jpg","res://images/des/2N.jpg","res://images/des/3N.jpg","res://images/des/4N.jpg","res://images/des/5N.jpg","res://images/des/6N.jpg"],
#	["res://images/des/1Y.jpg","res://images/des/2Y.jpg","res://images/des/3Y.jpg","res://images/des/4Y.jpg","res://images/des/5Y.jpg","res://images/des/6Y.jpg"],
#	["res://images/des/1R.jpg","res://images/des/2R.jpg","res://images/des/3R.jpg","res://images/des/4R.jpg","res://images/des/5R.jpg","res://images/des/6R.jpg"]
#]
var desImages = [
	"res://images/des/W.jpg",
	"res://images/des/B.jpg",
	"res://images/des/P.jpg",
	"res://images/des/G.jpg",
	"res://images/des/Y.jpg",
	"res://images/des/R.jpg",
	"res://images/des/M.jpg",
	"res://images/des/N.jpg"]

# Répartition des dés des joueurs
#var repartition = [null,null,null,null,null,null]

# Les noeuds des casinos 
var casinoNode = [null,null,null,null,null,null]

# Les billets de chaque casino
var billets_casinos = [
	[],
	[],
	[],
	[],
	[],
	[]]

var mes_billets = []
# Les dés de chaque casino
var des_casinos = [
	[],
	[],
	[],
	[],
	[],
	[],
]

var des_joueur = []

var id

func _ready():
	# Le noeud vers spatial (C6)
	SpatialNode = get_tree().get_root().get_node("ControlGame").get_node("Spatial")
	# Pointeur vers l'instance future de la classe MyMesh (C6)
	myMeshRessource = load("res://MyMesh.gd")
	
	# Créer dynamiquement les noeuds des casinos en fils de ce noeud là (C5)
	for i in range(6):
		var posz = poscasinos(i)
		casinoNode[i] = createCasino(0,0,posz,casinoImages[i])
	

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<< CRÉATION DE NOEUDS >>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Créer un casino d'image imgName à la position indiquée
func createCasino(posx,posy,posz,imgName):
	#Créer un pointeur vers la nouvelle instance qu'on vient veut créer 
	var mi = myMeshRessource.new()
	
	# Positioner le casino au bon endroit
	mi.set_translation(Vector3(posx,posy,posz))
	
	# Récupérer le maillage de l'objet
	var meshObj = load("res://blender/casino03.obj")
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

# Créer un billet de valeur nombre (1->9) à la position indiquée
func createBillet(posx,posy,posz,nombre):
	#Créer un pointeur vers la nouvelle instance qu'on vient veut créer 
	var mi = myMeshRessource.new()
	
	# Positioner le casino au bon endroit
	mi.set_translation(Vector3(posx,posy,posz))
	
	# Récupérer le maillage de l'objet
	var meshObj = load("res://blender/billet01.obj")
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

func createDe(posx,posy,posz,couleur,num):
	#Créer un pointeur vers la nouvelle instance qu'on vient veut créer 
	var mi = myMeshRessource.new()
	
	# Positioner le dé au bon endroit
	mi.set_translation(Vector3(posx,posy,posz))
	roterde(mi,num)
	# Récupérer le maillage de l'objet
	var meshObj = load("res://blender/de01.obj")
	mi.mesh = meshObj
	
	# Associer une surface au dé
	var surface_material = SpatialMaterial.new()
	mi.set_surface_material(0,surface_material)
	
	# Associer la texture 
	var texture = ImageTexture.new()
	texture.load(desImages[couleur])
	surface_material.albedo_texture = texture
	
	# Ajouter le dé en tant que child
	SpatialNode.add_child(mi)
	return mi
	
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<< AUTRES FONCTIONS >>>>>>>>>>>>>>>>>>>>>>>>>>>>
func creer_des(idj):
	# Créer dynamiquement les noeuds des dés en fils de ce noeud là (C5)
	for i in range(8):
		des_joueur.append(createDe(12,0,i*1.2,idj,1))
	


# Position par défaut d'un casino en fonction de son numéro
func poscasinos(num):
	return 12*num-45	

# Ajouter un billet billet au casino num
func add_billet_cas(num, billet):
	print("ajouter le billet "+String(billet)+" au casino "+String(num))
	var posx = 4
	var posy = -(billets_casinos[num].size()+1)*0.01
	var posz = poscasinos(num)+billets_casinos[num].size()*2 - 2
	billets_casinos[num].append(createBillet(posx,posy,posz,billet))
	

# Ajouter un nombre de dés des d'un joueur joueur au casino casino
func add_des_cas(joueur, des, casino):
	for d in range(des):
		print("Ajouter %d dés au casino %d pour le joueur %d"%[des,casino,joueur])
		var posx = 1-des_casinos[casino].size()*1.2
		var posy = 1
		var posz = poscasinos(casino)
		des_casinos[casino].append(createDe(posx,posy,posz,joueur,casino+1))
		

# Affiche le résultat du tirage
func afficher_des(des):
	print("Afficher la répartition")
	var cpt = 0
	for i in range(des.size()):
		for j in range(des[i]):
			roterde(des_joueur[cpt],i+1)
			des_joueur[cpt].set_translation(Vector3(12+j*1.2,2,-i*1.2))
			cpt+=1


func roterde(de,nombre):
	match nombre :
		1 : de.set_rotation(Vector3(PI/2,0,0))
		2 : de.set_rotation(Vector3(0,0,PI/2))
		3 : de.set_rotation(Vector3(0,0,0))
		4 : de.set_rotation(Vector3(0,0,PI))
		5 : de.set_rotation(Vector3(0,0,-PI/2))
		6 : de.set_rotation(Vector3(-PI/2,0,0))

func remove_des(des,nombre):
	print("Retirer les dés numéro %d +1 = %d"%[nombre,nombre+1])
	var to_erase = []
	var cpt = 0
	for i in range(des.size()):
		for j in range(des[i]):
			if i == nombre:
				to_erase.append(des_joueur[cpt])
			cpt+=1
	
	print("Donc retirer %d dés "%to_erase.size())
	for de in to_erase:
		remove_child(de)
		des_joueur.erase(de)

func recup_billet_cas(casino, billet):
	billets_casinos[casino][billet].set_translation(Vector3(14,mes_billets.size()*0.1,-mes_billets.size()))
	mes_billets.append(billets_casinos[casino][billet])

func remove_billet_cas(casino, billet):
	remove_child(billets_casinos[casino][billet])
	billets_casinos[casino].erase(billets_casinos[casino][billet])
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

