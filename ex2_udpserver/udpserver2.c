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
#define NB_MAX_JOUEURS 6

// <<<<<<<<<<<<<<<<<<<<<<<<<<<< Les clients >>>>>>>>>>>>>>>>>>>>
struct _client
{
        char ipAddress[40];
        int port;
        char name[40];
        int nb_des;
} tcpClients[NB_MAX_JOUEURS];

int nb_clients;

struct _casino
{
		int billets[5];
		int nb_billets;
        int rep_des[NB_MAX_JOUEURS];
} casinos[6];

void printClients()
{
        int i;

        for (i=0;i<nb_clients;i++)
                printf("%d: %s %5.5d %s\n",i,tcpClients[i].ipAddress,
                        tcpClients[i].port,
                        tcpClients[i].name);
}

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

void repondre_connection(int id,char*reply)
{
	sprintf(reply,"TONID %d",id);

}

int statut_partie;


void distribuer_billets()
{
	int total ;
	for (int i = 0; i<6; i++)
	{
		total = 0;
		for (int j=0;j<5 && total <5;j++)
		{
			casinos[i].billets[j]+=rand()%9+1;
			total+=casinos[i].billets[j];
			casinos[i].nb_billets+=1;
		}
	}
	char reply[MAXLINE];
	for(int i = 0; i<1/*NB_MAX_JOUEURS*/; i++)
	{
		for(int j=0; j<6;j++)
		{
			for(int k=0; k<casinos[j].nb_billets;k++)
			{
				sprintf(reply,"B%d%d",j,casinos[j].billets[k]-1);
				sendMessageToGodotClient(tcpClients[i].ipAddress,tcpClients[i].port, reply);
			}
		}
	}

}
void placer_des_casino(int id_j, int nb_d, int no_c)
{
    if(tcpClients[id_j].nb_des -nb_d >= 0)
    {
        tcpClients[id_j].nb_des = tcpClients[id_j].nb_des - nb_d;
        casinos[no_c].rep_des[id_j] = nb_d;
    }

}

// Demande de lancer les dés
void tour_suivant(int idj)
{
    char reply[MAXLINE];
    sprintf(reply,"T%d",tcpClients[idj].nb_des);
    sendMessageToGodotClient(tcpClients[idj].ipAddress,tcpClients[idj].port,reply);
}

int get_nb_des(int id_j)
{
    return 0;
}
int main()
{

	srand(time(NULL));
	// Initialisation des valeurs
	statut_partie = 0; // 0:attente, 1: en cours, 2:fin
	nb_clients = 0;
	int id_joueur_en_cours = 0;

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

		sprintf(reply,"W REPONSE VIDE");
		// <<<<<<<<<<<<<<< Traitement >>>>>>>>>>>>>>
		if(statut_partie == 0)
		{
			switch(buffer[0])
            {
				case 'C' : // Connection d'un nouveau joueur
					sprintf(tcpClients[nb_clients].ipAddress,addresse_client);
					tcpClients[nb_clients].port=port_client;
                    tcpClients[nb_clients].nb_des = 8;
					repondre_connection(nb_clients++,reply);

                    // Indiquer à chacun combien il reste de joueurs pour commencer
                    char ilreste[MAXLINE];
					sprintf(ilreste,"Z%d",6-nb_clients);
					for(int i=0; i<nb_clients; i++)
					{
						sendMessageToGodotClient(tcpClients[i].ipAddress,tcpClients[i].port,ilreste);
					}

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

		else if(statut_partie == 1)
		{
			switch(buffer[0])
			{
				case 'C' : ;// Connection à refuser
					sprintf(reply,"W Partie déjà en cours");
	                break;

				case 'P': ; // Placement des dés
                    // Le joueur id place nb_d dés sur le casino no_c
					int id_j, nb_d, no_c;
					sscanf(buffer,"P %d %d %d",&id_j,&nb_d,&no_c);

                    // Cas d'erreur :
					if(id_j!=id_joueur_en_cours)
						sprintf(reply,"W Ce n'est pas à toi (%d) de lancer mais à %d",id_j, id_joueur_en_cours);
                    else if(nb_d > get_nb_des(id_j) | nb_d < 1)
						sprintf(reply,"W Nombre de dés (%d) incorrect",nb_d);
                    else if(no_c < 1 | no_c > 6)
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

                        tour_suivant(++id_joueur_en_cours);
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
