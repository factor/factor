#include "factor.h"

int make_server_socket(CHAR port)
{
	int sock;
	struct sockaddr_in name;
	
	int reuseaddr = 1;
	
	/* Create the socket */
	sock = socket(PF_INET, SOCK_STREAM, 0);
	
	if(sock < 0)
		io_error(NULL,__FUNCTION__);
	
	/* Reuse port number */
	if(setsockopt(sock,SOL_SOCKET,SO_REUSEADDR,&reuseaddr,sizeof(int)) < 0)
		io_error(NULL,__FUNCTION__);
	
	/* Give the socket a name */
	name.sin_family = AF_INET;
	name.sin_port = htons(port);
	name.sin_addr.s_addr = htonl(INADDR_ANY);
	if(bind(sock,(struct sockaddr *)&name, sizeof(name)) < 0)
	{
		close(sock);
		io_error(NULL,__FUNCTION__);
	}

	/* Start listening for connections */
	if(listen(sock,1) < 0)
	{
		close(sock);
		io_error(NULL,__FUNCTION__);
	}

	return sock;
}

void primitive_server_socket(void)
{
	CHAR p = (CHAR)to_fixnum(dpop());
	dpush(tag_object(port(make_server_socket(p))));
}

int accept_connection(int sock)
{
	struct sockaddr_in clientname;
	size_t size = sizeof(clientname);
	
	int new = accept(sock,(struct sockaddr *)&clientname,&size);
	if(new < 0)
		io_error(NULL,__FUNCTION__);

	printf("Connection from host %s, port %hd.\n",
		inet_ntoa(clientname.sin_addr),
		ntohs(clientname.sin_port));

	return new;
}

void primitive_accept_fd(void)
{
	PORT* p = untag_port(dpop());
	PORT* new = port(accept_connection(p->fd));
	dpush(tag_object(new));
}
