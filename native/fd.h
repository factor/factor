#define LINE_SIZE 80
#define BUF_SIZE (32 * 1024)

int read_step(PORT* port);

/* read_line_step() return values */
typedef enum { READLINE_AGAIN, READLINE_EOL, READLINE_EOF } READLINE_STAT;

READLINE_STAT read_line_step(PORT* port);
void flush_buffer(PORT* port);
void init_io(void);
void primitive_read_line_fd_8(void);
void write_fd_char_8(PORT* port, FIXNUM ch);
void write_fd_string_8(PORT* port, STRING* str);
void primitive_write_fd_8(void);
void primitive_flush_fd(void);
void primitive_close_fd(void);
