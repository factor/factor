#include "factor.h"

int make_server_socket(CHAR port)
{
	int sock;
	struct sockaddr_in name;
	
	/* Create the socket */
	sock = socket(PF_INET, SOCK_STREAM, 0);
	
	if(sock < 0)
		return -1;
	
	/* Give the socket a name */
	name.sin_family = AF_INET;
	name.sin_port = htons(port);
	name.sin_addr.s_addr = htonl(INADDR_ANY);
	if(bind(sock,(struct sockaddr *)&name, sizeof(name)) < 0)
		return -1;

	/* Start listening for connections */
	if(listen(sock,1) < 0)
		return -1;

	return sock;
}

void primitive_server_socket(void)
{
	CHAR port = (CHAR)untag_fixnum(env.dt);
	env.dt = handle(HANDLE_FD,make_server_socket(port));
}

int accept_connection(int sock)
{
	struct sockaddr_in clientname;
	size_t size = sizeof(clientname);
	
	int new = accept(sock,(struct sockaddr *)&clientname,&size);
	if(new < 0)
		return -1;

	printf("Connection from host %s, port %hd.\n",
		inet_ntoa(clientname.sin_addr),
		ntohs(clientname.sin_port));

	return new;
}

void primitive_accept_fd(void)
{
	HANDLE* h = untag_handle(HANDLE_FD,env.dt);
	env.dt = handle(HANDLE_FD,accept_connection(h->object));
}
