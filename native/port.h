#define BUF_SIZE (8 * 1024)

typedef enum {
	PORT_READ,
	PORT_RECV,
	PORT_WRITE,
	PORT_SPECIAL
} PORT_MODE;

typedef struct {
	CELL header;
	PORT_MODE type;
	bool closed;
	F_FIXNUM fd;
	CELL buffer;

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
	F_FIXNUM count;

	/* tagged client info used by accept_fd */
	CELL client_host;
	CELL client_port;
	/* untagged fd of accepted connection */
	CELL client_socket;

	/* a pending I/O error or F */
	CELL io_error;
} F_PORT;

F_PORT* untag_port(CELL tagged);
F_PORT* port(PORT_MODE type, CELL fd);
void init_line_buffer(F_PORT* port, F_FIXNUM count);
void fixup_port(F_PORT* port);
void collect_port(F_PORT* port);
void postpone_io_error(F_PORT* port, const char* func);
void io_error(const char* func);
void pending_io_error(F_PORT* port);
void primitive_pending_io_error(void);
