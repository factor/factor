typedef enum { PORT_READ, PORT_WRITE, PORT_SPECIAL } PORT_MODE;

typedef struct {
	CELL header;
	/* one of PORT_READ or PORT_WRITE */
	PORT_MODE type;
	FIXNUM fd;
	STRING* buffer;
	/* tagged partial line used by read_line_fd */
	CELL line;
	/* tagged client info used by accept_fd */
	CELL client_host;
	CELL client_port;
	/* untagged fd of accepted connection */
	CELL client_socket;
	/* top of buffer */
	CELL buf_fill;
	/* current read/write position */
	CELL buf_pos;
} PORT;

PORT* untag_port(CELL tagged);
PORT* port(PORT_MODE type, CELL fd);
void primitive_portp(void);
void fixup_port(PORT* port);
void collect_port(PORT* port);
