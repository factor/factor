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

void add_io_task_impl(
	IO_TASK_TYPE type,
	PORT* port,
	CELL callback,
	fd_set* fdset,
	IO_TASK* io_tasks,
	int* fd_count)
{
	int fds = *fd_count;

	/* Look for an empty slot first */
	int i;
	for(i = 0; i < fds; i++)
	{
		if(io_tasks[i].port == F)
		{
			FD_SET(port->fd,fdset);
			io_tasks[i].type = type;
			io_tasks[i].port = tag_object(port);
			io_tasks[i].callback = callback;
			return;
		}
	}

	/* add at end */
	if(fds == FD_SETSIZE)
		critical_error("Too many I/O tasks",*fd_count);

	FD_SET(port->fd,fdset);
	io_tasks[fds].type = type;
	io_tasks[fds].port = tag_object(port);
	io_tasks[fds].callback = callback;
	*fd_count = fds + 1;
}

void add_io_task(IO_TASK_TYPE type, PORT* port, CELL callback)
{
	switch(type)
	{
	case IO_TASK_READ_LINE:
	case IO_TASK_READ_COUNT:
		add_io_task_impl(type,port,callback,
			&read_fd_set,read_io_tasks,
			&read_fd_count);
		break;
	case IO_TASK_WRITE:
		add_io_task_impl(type,port,callback,
			&write_fd_set,write_io_tasks,
			&write_fd_count);
		break;
	}
}

void remove_io_task_impl(
	IO_TASK_TYPE type,
	PORT* port,
	fd_set* fdset,
	IO_TASK* io_tasks,
	int* fd_count)
{
	int i;
	int fds = *fd_count;

	for(i = 0; i < fds; i++)
	{
		if(untag_port(io_tasks[i].port) == port)
		{
			FD_CLR(port->fd,fdset);
			io_tasks[i].port = F;
			io_tasks[i].callback = F;
			if(i == fds - 1)
				*fd_count = fds - 1;
			return;
		}
	}
}

void remove_io_task(IO_TASK_TYPE type, PORT* port)
{
	switch(type)
	{
	case IO_TASK_READ_LINE:
	case IO_TASK_READ_COUNT:
		remove_io_task_impl(type,port,
			&read_fd_set,read_io_tasks,
			&read_fd_count);
		break;
	case IO_TASK_WRITE:
		remove_io_task_impl(type,port,
			&write_fd_set,write_io_tasks,
			&write_fd_count);
	}
}

void perform_iotask(IO_TASK* task)
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

/* Wait for I/O and return a callback. */
CELL iomux(void)
{
	int nfds = select(read_fd_count > write_fd_count
		? read_fd_count : write_fd_count,
		&read_fd_set,&write_fd_set,NULL,NULL);

	/* int i;

	for(i = 0; i < read_fd_count; i++)
		perform_iotask(&read_io_tasks[i]);

	for(i = 0; i < write_fd_count; i++)
		perform_iotask(&write_io_tasks[i]); */

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
