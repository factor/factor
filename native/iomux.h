typedef enum {
	IO_TASK_READ_LINE,
	IO_TASK_READ_COUNT,
	IO_TASK_WRITE
} IO_TASK_TYPE;

typedef struct {
	IO_TASK_TYPE type;
	CELL port;
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
void add_io_task_impl(
	IO_TASK_TYPE type,
	PORT* port,
	CELL callback,
	fd_set* fdset,
	IO_TASK* io_tasks,
	int* fd_count);
void add_io_task(IO_TASK_TYPE type, PORT* port, CELL callback);
void remove_io_task_impl(
	IO_TASK_TYPE type,
	PORT* port,
	fd_set* fdset,
	IO_TASK* io_tasks,
	int* fd_count);
void remove_io_task(IO_TASK_TYPE type, PORT* port);
CELL iomux(void);
void collect_io_tasks(void);
