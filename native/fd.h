#define LINE_SIZE 80
#define BUF_SIZE 1024

void init_io(void);
void primitive_close_fd(void);
int fill_buffer(HANDLE* h, int fd, STRING* buf);
void primitive_read_line_fd_8(void);
void primitive_write_fd_8(void);
void primitive_flush_fd(void);
void primitive_shutdown_fd(void);
