void init_sockaddr(struct sockaddr_in *name,
	const char *hostname, uint16_t port);
int make_client_socket(const char* hostname, uint16_t port);
void primitive_client_socket(void);
int make_server_socket(uint16_t port);
void primitive_server_socket(void);
CELL accept_connection(PORT* p);
void primitive_accept_fd(void);
