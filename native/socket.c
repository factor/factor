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

CELL accept_connection(PORT* p)
{
	struct sockaddr_in clientname;
	size_t size = sizeof(clientname);
	
	int new = accept(p->fd,(struct sockaddr *)&clientname,&size);
	if(new < 0)
	{
		if(errno == EAGAIN)
			return false;
		else
			io_error(NULL,__FUNCTION__);
	}

	p->client_host = tag_object(from_c_string(inet_ntoa(
		clientname.sin_addr)));
	p->client_port = tag_fixnum(ntohs(clientname.sin_port));
	p->client_socket = tag_object(port(new));

	return true;
}

void primitive_accept_fd(void)
{
	PORT* port = untag_port(dpop());
	dpush(port->client_host);
	dpush(port->client_port);
	dpush(port->client_socket);
}
