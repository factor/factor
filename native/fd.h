#define LINE_SIZE 80
#define BUF_SIZE (32 * 1024)

bool can_read_line(PORT* port);
void primitive_can_read_line(void);
bool read_step(PORT* port);
bool read_line_step(PORT* port);

bool write_step(PORT* port);
void flush_buffer(PORT* port);
void init_io(void);
void primitive_read_line_fd_8(void);
bool can_write(PORT* port, FIXNUM len);
void primitive_can_write(void);
void write_fd_char_8(PORT* port, FIXNUM ch);
void write_fd_string_8(PORT* port, STRING* str);
void primitive_write_fd_8(void);
void primitive_close_fd(void);
void io_error(const char* func);
