typedef struct {
	CELL header;
	FIXNUM fd;
	STRING* buffer;
	CELL buf_mode;
	CELL buf_fill;
	CELL buf_pos;
} PORT;

/* Buffer mode */
#define B_READ 0
#define B_WRITE 1
#define B_NONE 2

PORT* untag_port(CELL tagged);
CELL port(CELL fd);
void init_buffer(PORT* port, int mode);
void primitive_portp(void);
void fixup_port(PORT* port);
void collect_port(PORT* port);
