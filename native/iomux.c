#include "factor.h"

void init_iomux(void)
{
	io_task_count = 0;
}

void add_io_task(int fd, int events, CELL callback)
{
	/* Look for an empty slot first */
	int i;
	for(i = 0; i < io_task_count; i++)
	{
		if(io_tasks[i].fd == -1)
		{
			io_tasks[i].fd = fd;
			io_tasks[i].events = events;
			io_callbacks[i] = callback;
			return;
		}
	}

	/* Add to the end */
	if(io_task_count == MAX_IO_TASKS)
		critical_error("Too many I/O tasks",io_task_count);

	io_tasks[io_task_count].fd = fd;
	io_tasks[io_task_count].events = events;
	io_callbacks[io_task_count] = callback;
	io_task_count++;
}
