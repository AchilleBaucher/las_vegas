// Server side implementation of an UDP client-server model
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <netdb.h>
#include <time.h>

#define PORT	 	4242
#define GODOT_PORT	4000
#define MAXLINE 	1024
#define NB_MAX_JOUEURS 2
#define NB_CASINOS 6

// <<<<<<<<<<<<<<<<<<<<<<<<<<<< Initialisation >>>>>>>>>>>>>>>>>>>>

// Structure client, stocke des infos sur un client godot
struct _client
{
    char ipAddress[40];
    int port;
    char name[40];
    int nb_des;
    int nbrBilet;
    int score;
} tcpClients[NB_MAX_JOUEURS];

// Nombre de joueurs participants
int nb_clients;

// Un casino, contient ses billets et ses dés
struct _casino
{
    // Il y a maximum 5 billets, sa vraie valeur est x10 000 (3 = 30 000)
	int billets[5];
	int nb_billets;

    // Pour chaque joueur, le nombre de dés qu'il a sur ce casino
    int rep_des[NB_MAX_JOUEURS];
} casinos[NB_CASINOS];

// Affiche tous les clients
void printClients()
{
    int i;

    for (i=0;i<nb_clients;i++)
            printf("%d: %s %5.5d %s\n",i,
                tcpClients[i].ipAddress,
                tcpClients[i].port,
                tcpClients[i].name);
}

// Initialisation de tous les clients à des trucs
void initialiser_clients()
{
	// Initialisation des clients
	for (int i=0;i<NB_MAX_JOUEURS;i++)
	{
		strcpy(tcpClients[i].ipAddress,"temporaire");
		tcpClients[i].port=-1;
		strcpy(tcpClients[i].name,"-");
	}
}

// Envoie un message à un client godot
void sendMessageToGodotClient(char *hostname,int portno, char *mess)
{
    printf("Envoyer le paquet : \n\"%s\"\n au client %s:%d\n",mess,
        hostname, portno);

    	/* socket: create the socket */
	int socketGodot;
	struct hostent *serverGodot;
	int serverlen;
	struct sockaddr_in serverGodotAddr;
	int n;
	char sendBuffer[MAXLINE];

    	socketGodot = socket(AF_INET, SOCK_DGRAM, 0);
    	if (socketGodot < 0)
	{
        	printf("ERROR opening socketGodot\n");
		exit(1);
	}

    	/* gethostbyname: get the server's DNS entry */
    	serverGodot = gethostbyname(hostname);
    	if (serverGodot == NULL)
	{
        	fprintf(stderr,"ERROR, no such host as %s\n", hostname);
        	exit(1);
    	}

    	/* build the server's Internet address */
    	bzero((char *) &serverGodotAddr, sizeof(serverGodotAddr));
    	serverGodotAddr.sin_family = AF_INET;
    	bcopy((char *)serverGodot->h_addr,
          	(char *)&serverGodotAddr.sin_addr.s_addr, serverGodot->h_length);
    	serverGodotAddr.sin_port = htons(portno);

    	bzero((char *) sendBuffer, MAXLINE);
	sprintf(sendBuffer,"ABCDEFGHIJKLMNOPQRSTUVWXYZ");

    	/* send the message to the server */
    	serverlen = sizeof(serverGodotAddr);
    	//n = sendto(socketGodot, sendBuffer, strlen(sendBuffer), 0,
    	n = sendto(socketGodot, mess, strlen(mess), 0,
		(struct sockaddr *)&serverGodotAddr, serverlen);
    	if (n < 0)
	{
		printf("ERROR in sendto\n");
		exit(1);
	}
	close(socketGodot);
}

// Distribue aléatoirement des billets sur chaque casino en début de partie
void distribuer_billets()
{
    // Quantité d'argent sur un casino
	int total ;

    // Pour chaque casino
	for (int i = 0; i<NB_CASINOS; i++)
	{
		total = 0;
        // Tant qu'on es pas à plus de 50 000
		for (int j=0;j<5 && total <5;j++)
		{
            // On met un nouveau billet aléatoirement
			casinos[i].billets[j]+=rand()%9+1;
			total+=casinos[i].billets[j];
			casinos[i].nb_billets+=1;
		}

		// Tri par sélection des billets
		int c;
		for(int u=0;u<4;u++)
		{
			for(int v=u+1;v<5;v++)
		    {
		    	if ( casinos[i].billets[u] > casinos[i].billets[v] ) 
		        {
		            c = casinos[i].billets[u];
		            casinos[i].billets[u] = casinos[i].billets[v];
		            casinos[i].billets[v] = c;
		        }
		    }
		}

	}

    // Ceci fait, on envoie à tous les clients du jeu les nouveaux billets
    // !# Attention, et si moins de joueurs que NB_MAX_JOUEURS ?

    // La réponse
	char reply[MAXLINE];

    // Pour chaque joueur
	for(int i = 0; i<NB_MAX_JOUEURS; i++)
	{
        // Pour chaque casino
		for(int j=0; j<NB_CASINOS;j++)
		{
			for(int k=0; k<casinos[j].nb_billets;k++)
            // Pour chaque billet
			{
                // Envoyer le message du billet
				sprintf(reply,"B%d%d",j,casinos[j].billets[k]-1);
				sendMessageToGodotClient(tcpClients[i].ipAddress,tcpClients[i].port, reply);

			}
		}
	}
}



void trie_selec_indice(int* tableau_val, int* tableau_ind, int N)
{
	// Tri par sélection 
	int c;
	for(int i=0;i<N-1;i++)
	{
		for(int j=i+1;j<N;j++)
	    {
	    	if ( tableau_val[i] > tableau_val[j] ) 
	        {
	        	// On trie le tableau du nombre de des
	            c = tableau_val[i];
	            tableau_val[i] = tableau_val[j];
	            tableau_val[j] = c;

	            // On trie le tableau des indices des des avec le même ordre
	            c = tableau_ind[i];
	            tableau_ind[i] = tableau_ind[j];
	            tableau_ind[j] = c;
	        }
	    }
	}


}


void gains(int nb_client)
{
	for (int i = 0; i<NB_CASINOS; i++)
	{
		printf("--------------------\nCasino %d\n--------------------\n" ,i);
		int k = 0;
		// Tableau des indices des des
		int indice_des[nb_client];
		// On initialise le tableau des indices
		for (int a = 0; a<nb_client; a++)
		{
			indice_des[a] = a;
		}

		for (int y = 0; y < nb_client; y++)
		{
			printf("REP DES %d\nIND JOUEUR %D\n" ,casinos[i].rep_des[y], indice_des[y]);
		}

		trie_selec_indice(casinos[i].rep_des, indice_des, nb_client);

		for (int j = 0; j<nb_client; j++)
		{
			// on s'assure que le client n'a pas un nombre de dés égale à un ou plusieurs autres joueurs
			while(casinos[i].rep_des[j] == casinos[i].rep_des[j+1])
			{
				j++;
				if (casinos[i].rep_des[j] != casinos[i].rep_des[j+1])
				{
					j++;
				}
			}

			printf("Le client %d reçoit le billet %d du casino %d\n",indice_des[j],k ,i);
			// on augmente le nombre de billet
			tcpClients[indice_des[j]].nbrBilet++;
			// On ajoute la valeur du score
			tcpClients[indice_des[j]].score += casinos[i].billets[k];
			k++;

		}
		
	}

}

// Place les nb_d dés du joueur id_j sur le casino no_c
void placer_des_casino(int id_j, int nb_d, int no_c)
{
    if(tcpClients[id_j].nb_des -nb_d >= 0)
    {
        // Enlever le nombre de dés au joueur et ajouter ses dés sur le casino
        tcpClients[id_j].nb_des = tcpClients[id_j].nb_des - nb_d;
        casinos[no_c].rep_des[id_j] = nb_d;
    }

}

// Demande de à idj de lancer les dés
void tour_suivant(int idj)
{
    sendMessageToGodotClient(tcpClients[idj].ipAddress,tcpClients[idj].port,"T");
}


// 0:attente, 1: en cours, 2:fin
int statut_partie;

int main()
{

    // <<<<<<<<<<<<<<< Initialisation >>>>>>>>>>>>>>

	// Initialisation des valeurs
	statut_partie = 0;
	nb_clients = 0;
	int id_joueur_en_cours = 0;
    srand(time(NULL));

    // Scket
	int sockfd;
	char buffer[MAXLINE];
	struct sockaddr_in servaddr, cliaddr;

	// Creating socket file descriptor
	if ( (sockfd = socket(AF_INET, SOCK_DGRAM, 0)) < 0 ) {
		perror("socket creation failed");
		exit(EXIT_FAILURE);
	}

	memset(&servaddr, 0, sizeof(servaddr));
	memset(&cliaddr, 0, sizeof(cliaddr));

	// Filling server information
	servaddr.sin_family = AF_INET; // IPv4
	servaddr.sin_addr.s_addr = INADDR_ANY;
	servaddr.sin_port = htons(PORT);

	// Bind the socket with the server address
	if ( bind(sockfd, (const struct sockaddr *)&servaddr,
			sizeof(servaddr)) < 0 )
	{
		perror("bind failed");
		exit(EXIT_FAILURE);
	}

	int len, n;

	len = sizeof(cliaddr); //len is value/resuslt

	char reply[256];
	char* addresse_client;
	int port_client;

    // <<<<<<<<<<<<<<< Boucle >>>>>>>>>>>>>>
	while (1)
	{
		// <<<<<<<<<<<<<<< Réception >>>>>>>>>>>>>>
		n = recvfrom(sockfd, (char *)buffer, MAXLINE,
				MSG_WAITALL, ( struct sockaddr *) &cliaddr,
				&len);
		buffer[n] = '\0';
		addresse_client = inet_ntoa(cliaddr.sin_addr);
		port_client = ntohs(cliaddr.sin_port);

		// Affichage facultatif
		printf("Received packet from %s:%d\nData: [%s]\n\n",
        	addresse_client,port_client ,buffer);

        // Par défaut la réponse est comme ça
		sprintf(reply,"W REPONSE VIDE");

		// <<<<<<<<<<<<<<< Traitement >>>>>>>>>>>>>>

        // La partie n'a pas commencé
		if(statut_partie == 0)
		{
			switch(buffer[0])
            {
				case 'C' : // Connection d'un nouveau joueur
					sprintf(tcpClients[nb_clients].ipAddress,addresse_client);
					tcpClients[nb_clients].port=port_client;
                    tcpClients[nb_clients].nb_des = 8;


                    // Indiquer son ID au nouveau joueur, obligatoire
                    sprintf(reply,"I%d",nb_clients);
                    sendMessageToGodotClient(addresse_client,port_client,reply);
                    nb_clients++;

                    // Indiquer à chacun combien il reste de joueurs pour commencer
                    char ilreste[MAXLINE];
					sprintf(ilreste,"Z%d",NB_MAX_JOUEURS-nb_clients);
					for(int i=0; i<nb_clients; i++)
					{
						sendMessageToGodotClient(tcpClients[i].ipAddress,tcpClients[i].port,ilreste);
					}

					
					statut_partie =1;//!\\
                    // Si le nombre est atteint, on commence
					if(nb_clients >= NB_MAX_JOUEURS)
					{
						statut_partie =1;
						distribuer_billets();
                        tour_suivant(0);					}

                    break;


                default :
                    sprintf(reply,"W Commande incomprise");
                    break;

            }
        }

        // La partie a déjà commencé
		else if(statut_partie == 1)
		{
			switch(buffer[0])
			{

				case 'X' ://Distribtion des gains
					gains(2);
					casinos[0].rep_des[0] = 4;
					casinos[0].rep_des[1] = 4;
					for (int i =1; i<5; i++){
						casinos[0].rep_des[0] = 0;
						casinos[0].rep_des[0] = 0;
					}

                	sprintf(reply,"Tiens voilà tes billets");
                    sendMessageToGodotClient(addresse_client,port_client,reply);
                    break;



				case 'C' : ;// Connection à refuser

					sprintf(reply,"W Partie déjà en cours");
	                break;

				case 'P': ; // Placement des dés d'un joueur sur un casino

                    // Le joueur id place nb_d dés sur le casino no_c
					int id_j, nb_d, no_c;
					sscanf(buffer,"P %d %d %d",&id_j,&nb_d,&no_c);
                    printf("Recu de %d : mettre %d dés sur le casino %d\n",id_j,nb_d,no_c);
                    // Cas d'erreur :
					if(id_j!=id_joueur_en_cours)
						sprintf(reply,"W Ce n'est pas à toi (%d) de lancer mais à %d",id_j, id_joueur_en_cours);
                    else if(nb_d > tcpClients[id_j].nb_des | nb_d < 1)
						sprintf(reply,"W Nombre de dés (%d) incorrect",nb_d);
                    else if(no_c < 0 | no_c > NB_CASINOS)
						sprintf(reply,"W Numéro de casino (%d) incorrect",no_c);

                    // Cas de non erreur
                    else
                    {
                        placer_des_casino(id_j,nb_d,no_c);

                        // Préviens tout le monde des dés ajoutés
                        char des_ajoutes[MAXLINE];
                        sprintf(des_ajoutes,"D%d%d%d",id_j,nb_d,no_c);
                        for(int i=0; i<nb_clients; i++)
    					{
    						sendMessageToGodotClient(tcpClients[i].ipAddress,tcpClients[i].port,des_ajoutes);
    					}
                        id_joueur_en_cours = (id_joueur_en_cours+1)%nb_clients;
                        tour_suivant(id_joueur_en_cours);
                    }
				    break;

                default :
                    sprintf(reply,"W Commande incomprise");
			}
		}
		// <<<<<<<<<<<<<<< petite réponse de fin >>>>>>>>>>>>>>

		sendMessageToGodotClient(addresse_client,port_client,reply);
	}

	return 0;
}
