typedef enum { PORT_READ, PORT_RECV, PORT_WRITE, PORT_SPECIAL } PORT_MODE;

typedef struct {
	CELL header;
	/* one of PORT_READ, PORT_RECV, PORT_WRITE or PORT_SPECIAL */
	PORT_MODE type;
	FIXNUM fd;
	STRING* buffer;

	/* top of buffer */
	CELL buf_fill;
	/* current read/write position */
	CELL buf_pos;

	/* tagged partial line used by read_line_fd */
	CELL line;
	/* is it ready to be returned? */
	/* with the read# IO_TASK, this means that the operation is done */
	bool line_ready;

	/* count for read# */
	FIXNUM count;

	/* tagged client info used by accept_fd */
	CELL client_host;
	CELL client_port;
	/* untagged fd of accepted connection */
	CELL client_socket;
} PORT;

PORT* untag_port(CELL tagged);
PORT* port(PORT_MODE type, CELL fd);
void primitive_portp(void);
void fixup_port(PORT* port);
void collect_port(PORT* port);
