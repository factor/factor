#include "factor.h"

void init_io_tasks(fd_set* fdset, IO_TASK* io_tasks)
{
	int i;

	FD_ZERO(fdset);
	for(i = 0; i < FD_SETSIZE; i++)
	{
		read_io_tasks[i].port = F;
		read_io_tasks[i].callback = F;
	}
}

void init_iomux(void)
{
	read_fd_count = 0;
	init_io_tasks(&read_fd_set,read_io_tasks);

	write_fd_count = 0;
	init_io_tasks(&write_fd_set,write_io_tasks);
}

IO_TASK* add_io_task_impl(
	IO_TASK_TYPE type,
	PORT* port,
	CELL callback,
	IO_TASK* io_tasks,
	int* fd_count)
{
	int fd = port->fd;

	io_tasks[fd].type = type;
	io_tasks[fd].port = tag_object(port);
	io_tasks[fd].callback = callback;

	if(fd >= *fd_count)
		*fd_count = fd + 1;

	return &io_tasks[fd];
}

IO_TASK* add_io_task(IO_TASK_TYPE type, PORT* port, CELL callback)
{
	switch(type)
	{
	case IO_TASK_READ_LINE:
	case IO_TASK_READ_COUNT:
		return add_io_task_impl(type,port,callback,
			read_io_tasks,&read_fd_count);
	case IO_TASK_WRITE:
		return add_io_task_impl(type,port,callback,
			write_io_tasks,&write_fd_count);
	default:
		fatal_error("Invalid IO_TASK_TYPE",type);
		return NULL;
	}
}

void remove_io_task_impl(
	IO_TASK_TYPE type,
	PORT* port,
	IO_TASK* io_tasks,
	int* fd_count)
{
	int fd = port->fd;

	io_tasks[fd].port = F;
	io_tasks[fd].callback = F;

	if(fd == *fd_count - 1)
		*fd_count = *fd_count - 1;
}

void remove_io_task(IO_TASK_TYPE type, PORT* port)
{
	switch(type)
	{
	case IO_TASK_READ_LINE:
	case IO_TASK_READ_COUNT:
		remove_io_task_impl(type,port,read_io_tasks,&read_fd_count);
		break;
	case IO_TASK_WRITE:
		remove_io_task_impl(type,port,write_io_tasks,&write_fd_count);
		break;
	}
}

void perform_io_task(IO_TASK* task)
{
	if(task->port == F)
		return;

	switch(task->type)
	{
	case IO_TASK_READ_LINE:
		
		break;
	case IO_TASK_WRITE:
		write_step(untag_port(task->port));
		break;
	default:
		critical_error("Bad I/O task",task->type);
		break;
	}
}

bool set_up_fd_set(fd_set* fdset, IO_TASK* io_tasks)
{
	bool retval = false;
	
	int i;
	for(i = 0; i < read_fd_count; i++)
	{
		if(read_io_tasks[i].port != F)
		{
			retval = true;
			FD_SET(i,&read_fd_set);
		}
	}
	
	return retval;
}

/* Wait for I/O and return a callback. */
CELL iomux(void)
{
	bool reading = set_up_fd_set(&read_fd_set,read_io_tasks);
	bool writing = set_up_fd_set(&write_fd_set,write_io_tasks);

	if(!reading && !writing)
		fatal_error("iomux() called with no IO tasks",0);

	select(read_fd_count > write_fd_count
		? read_fd_count : write_fd_count,
		(reading ? &read_fd_set : NULL),
		(writing ? &write_fd_set : NULL),
		NULL,NULL);

	/* for(i = 0; i < read_fd_count; i++)
		perform_io_task(&read_io_tasks[i]);

	for(i = 0; i < write_fd_count; i++)
		perform_io_task(&write_io_tasks[i]); */

	return F;
}

void collect_io_tasks(void)
{
	int i;

	for(i = 0; i < FD_SETSIZE; i++)
	{
		copy_object(&read_io_tasks[i].port);
		copy_object(&read_io_tasks[i].callback);
	}

	for(i = 0; i < FD_SETSIZE; i++)
	{
		copy_object(&write_io_tasks[i].port);
		copy_object(&write_io_tasks[i].callback);
	}
}
