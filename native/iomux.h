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
IO_TASK* add_io_task_impl(
	IO_TASK_TYPE type,
	PORT* port,
	CELL callback,
	IO_TASK* io_tasks,
	int* fd_count);
IO_TASK* add_io_task(IO_TASK_TYPE type, PORT* port, CELL callback);
void remove_io_task_impl(
	IO_TASK_TYPE type,
	PORT* port,
	IO_TASK* io_tasks,
	int* fd_count);
void remove_io_task(IO_TASK_TYPE type, PORT* port);
void perform_io_task(IO_TASK* task);
bool set_up_fd_set(fd_set* fdset, IO_TASK* io_tasks);
CELL iomux(void);
void collect_io_tasks(void);
