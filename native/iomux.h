#define MAX_IO_TASKS 256
struct pollfd io_tasks[MAX_IO_TASKS];
CELL io_callbacks[MAX_IO_TASKS];
unsigned int io_task_count;

void init_iomux(void);
void add_io_task(int fd, int events, CELL callback);
