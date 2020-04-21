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
} tcpClients[NB_MAX_JOUEURS];

int nb_clients;

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
void debuter_partie(){

}
int main()
{
	// Initialisation des valeurs
	initialiser_clients();
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

		sprintf(reply,"REPONSE VIDE");
		// <<<<<<<<<<<<<<< Traitement >>>>>>>>>>>>>>
		if(statut_partie == 0)
		{
			switch(buffer[0])
			{
				case 'C' : // Connection d'un nouveau joueur
					repondre_connection(nb_clients++,reply);
					sendMessageToGodotClient(addresse_client,port_client,reply);
					if(nb_clients > NB_MAX_JOUEURS)
					{
						statut_partie =1;
						debuter_partie();
					}
			}
		}

		else if(statut_partie == 1)
		{
			switch(buffer[0])
			{
				case 'C' : ;// Connection à refuser
					sendMessageToGodotClient(addresse_client,port_client,"Partie déjà en cours");
				break;

				case 'L': ;// Lancement des dés
					int id_joueur, nombre_des;
					sscanf(buffer,"L %d %d",&id_joueur,&nombre_des);
					if(id_joueur!=id_joueur_en_cours)
					{
						sendMessageToGodotClient(addresse_client,port_client,"Ce n'est pas à toir de lancer");
					}
				break;
			}
		}
		// <<<<<<<<<<<<<<< petite réponse de fin >>>>>>>>>>>>>>
		char*reponse = "REPONSE";
		printf("Envoyer %s au client %s:%d\n",reply,
        	addresse_client, port_client);

		sendMessageToGodotClient(addresse_client,port_client,reply);
	}

	return 0;
}
