#include "factor.h"

void init_sockaddr(struct sockaddr_in* name,
	const char* hostname, uint16_t port)
{
	struct hostent *hostinfo;

	name->sin_family = AF_INET;
	name->sin_port = htons(port);
	hostinfo = gethostbyname(hostname);

	if(hostinfo == NULL)
		io_error(__FUNCTION__);

	name->sin_addr = *((struct in_addr *)hostinfo->h_addr);
}

int make_client_socket(const char* hostname, uint16_t port)
{
	int sock;
	struct sockaddr_in servername;

	/* Create the socket. */
	sock = socket(PF_INET,SOCK_STREAM,0);
	if(sock < 0)
		io_error(__FUNCTION__);

	/* if(fcntl(sock,F_SETFL,O_NONBLOCK,1) == -1)
		io_error(__FUNCTION__); */

	/* Connect to the server. */
	init_sockaddr(&servername,hostname,port);
	if(connect(sock,(struct sockaddr *)&servername,sizeof(servername)) < 0)
	{
		if(errno != EINPROGRESS)
		{
			close(sock);
			io_error(__FUNCTION__);
		}
	}

	return sock;
}

void primitive_client_socket(void)
{
	uint16_t p = (uint16_t)to_fixnum(dpop());
	char* host = to_c_string(untag_string(dpop()));
	int sock = make_client_socket(host,p);
	dpush(tag_object(port(PORT_READ,sock)));
	dpush(tag_object(port(PORT_WRITE,sock)));
}

int make_server_socket(uint16_t port)
{
	int sock;
	struct sockaddr_in name;
	
	int reuseaddr = 1;
	
	/* Create the socket */
	sock = socket(PF_INET, SOCK_STREAM, 0);
	
	if(sock < 0)
		io_error(__FUNCTION__);
	
	/* Reuse port number */
	if(setsockopt(sock,SOL_SOCKET,SO_REUSEADDR,&reuseaddr,sizeof(int)) < 0)
		io_error(__FUNCTION__);
	
	/* Give the socket a name */
	name.sin_family = AF_INET;
	name.sin_port = htons(port);
	name.sin_addr.s_addr = htonl(INADDR_ANY);
	if(bind(sock,(struct sockaddr *)&name, sizeof(name)) < 0)
	{
		close(sock);
		io_error(__FUNCTION__);
	}

	/* Start listening for connections */
	if(listen(sock,1) < 0)
	{
		close(sock);
		io_error(__FUNCTION__);
	}

	return sock;
}

void primitive_server_socket(void)
{
	uint16_t p = (uint16_t)to_fixnum(dpop());
	dpush(tag_object(port(PORT_SPECIAL,make_server_socket(p))));
}

CELL accept_connection(PORT* p)
{
	struct sockaddr_in clientname;
	size_t size = sizeof(clientname);
	
	int oobinline = 1;

	int new = accept(p->fd,(struct sockaddr *)&clientname,&size);
	if(new < 0)
	{
		if(errno == EAGAIN)
			return false;
		else
			io_error(__FUNCTION__);
	}

	/* if(setsockopt(new,SOL_SOCKET,SO_OOBINLINE,&oobinline,sizeof(int)) < 0)
		io_error(__FUNCTION__); */

	p->client_host = tag_object(from_c_string(inet_ntoa(
		clientname.sin_addr)));
	p->client_port = tag_fixnum(ntohs(clientname.sin_port));
	p->client_socket = new;

	return true;
}

void primitive_accept_fd(void)
{
	PORT* p = untag_port(dpop());
	dpush(p->client_host);
	dpush(p->client_port);
	dpush(tag_object(port(PORT_READ,p->client_socket)));
	dpush(tag_object(port(PORT_WRITE,p->client_socket)));
}
