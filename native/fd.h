#define LINE_SIZE 80
#define BUF_SIZE (32 * 1024)

int fill_buffer(HANDLE* h, int fd, STRING* buf);
void flush_buffer(HANDLE* h);
void write_fully(HANDLE* h, char* str, CELL len);
void init_io(void);
void primitive_read_line_fd_8(void);
void write_fd_char_8(HANDLE* h, FIXNUM ch);
void write_fd_string_8(HANDLE* h, STRING* str);
void primitive_write_fd_8(void);
void primitive_flush_fd(void);
void primitive_close_fd(void);
