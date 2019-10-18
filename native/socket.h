void init_sockaddr(struct sockaddr_in *name,
	const char *hostname, uint16_t port);
int make_client_socket(const char* hostname, uint16_t port);
void primitive_client_socket(F_WORD *);
int make_server_socket(uint16_t port);
void primitive_server_socket(F_WORD *);
void primitive_add_accept_io_task(F_WORD *);
CELL accept_connection(F_PORT* p);
void primitive_accept_fd(F_WORD *);
