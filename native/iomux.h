typedef struct {
	PORT* port;
	CELL callback;
} IO_TASK;

fd_set read_fd_set;
IO_TASK read_io_tasks[FD_SETSIZE];
int read_fd_count;

fd_set write_fd_set;
IO_TASK write_io_tasks[FD_SETSIZE];
int write_fd_count;

void init_io_tasks(fd_set* fd_set, IO_TASK* io_tasks);
void init_iomux(void);
void add_io_task(
	PORT* port,
	CELL callback,
	fd_set* fd_set,
	IO_TASK* io_tasks,
	int* fd_count);
void add_read_io_task(PORT* port, CELL callback);
void add_write_io_task(PORT* port, CELL callback);
void remove_io_task(
	PORT* port,
	fd_set* fdset,
	IO_TASK* io_tasks,
	int* fd_count);
void remove_read_io_task(PORT* port);
void remove_write_io_task(PORT* port);
CELL iomux(void);
