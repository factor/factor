FILE* debug_fd;

typedef enum {
	IO_TASK_READ_LINE,
	IO_TASK_READ_COUNT,
	IO_TASK_WRITE,
	IO_TASK_ACCEPT,
	IO_TASK_COPY_FROM,
	IO_TASK_COPY_TO
} IO_TASK_TYPE;

typedef struct {
	IO_TASK_TYPE type;
	CELL port;
	/* Used for COPY_FROM and COPY_TO only */
	CELL other_port;
	/* TAGGED list of callbacks, or F */
	/* Multiple callbacks per port are only permitted for IO_TASK_WRITE. */
	CELL callbacks;
} IO_TASK;

fd_set read_fd_set;
IO_TASK read_io_tasks[FD_SETSIZE];
int read_fd_count;

fd_set write_fd_set;
IO_TASK write_io_tasks[FD_SETSIZE];
int write_fd_count;

fd_set except_fd_set;

void init_io_tasks(fd_set* fd_set, IO_TASK* io_tasks);
void init_io(void);
IO_TASK* add_io_task(
	IO_TASK_TYPE type,
	CELL port,
	CELL other_port,
	CELL callback,
	IO_TASK* io_tasks,
	int* fd_count);
void remove_io_task(
	PORT* port,
	IO_TASK* io_tasks,
	int* fd_count);
void remove_io_tasks(PORT* port);
bool perform_copy_from_io_task(PORT* port, PORT* other_port);
bool perform_copy_to_io_task(PORT* port, PORT* other_port);
void primitive_add_copy_io_task(void);
CELL pop_io_task_callback(
	IO_TASK_TYPE type,
	PORT* port,
	IO_TASK* io_tasks,
	int* fd_count);
bool set_up_fd_set(fd_set* fdset, int fd_count, IO_TASK* io_tasks,
	bool* closed);
CELL perform_io_task(IO_TASK* io_task, IO_TASK* io_tasks, int* fd_count);
CELL perform_io_tasks(fd_set* fdset, IO_TASK* io_tasks, int* fd_count);
CELL next_io_task(void);
void primitive_next_io_task(void);
void primitive_close(void);
void collect_io_tasks(void);
