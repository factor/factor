#define LINE_SIZE 80
#define BUF_SIZE (32 * 1024)

int read_step(PORT* port, STRING* buf);
void flush_buffer(PORT* port);
void write_fully(PORT* port, char* str, CELL len);
void init_io(void);
void primitive_read_line_fd_8(void);
void write_fd_char_8(PORT* port, FIXNUM ch);
void write_fd_string_8(PORT* port, STRING* str);
void primitive_write_fd_8(void);
void primitive_flush_fd(void);
void primitive_close_fd(void);
