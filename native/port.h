/* Buffer mode */
typedef enum { B_READ_LINE, B_WRITE, B_NONE } B_MODE;

typedef struct {
	CELL header;
	FIXNUM fd;
	STRING* buffer;
	/* tagged partial line used by read_line_fd */
	CELL line;
	/* one of B_READ, B_WRITE or B_NONE */
	B_MODE buf_mode;
	/* top of buffer */
	CELL buf_fill;
	/* current read/write position */
	CELL buf_pos;
} PORT;

PORT* untag_port(CELL tagged);
PORT* port(CELL fd);
void init_buffer(PORT* port, int mode);
void primitive_portp(void);
void fixup_port(PORT* port);
void collect_port(PORT* port);
