#include "factor.h"

void init_io_tasks(fd_set* fdset, IO_TASK* io_tasks)
{
	int i;

	FD_ZERO(fdset);
	for(i = 0; i < FD_SETSIZE; i++)
	{
		read_io_tasks[i].port = NULL;
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

void add_io_task(
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
		if(io_tasks[i].port == NULL)
		{
			FD_SET(port->fd,fdset);
			io_tasks[i].port = port;
			io_tasks[i].callback = callback;
			return;
		}
	}

	/* add at end */
	if(fds == FD_SETSIZE)
		critical_error("Too many I/O tasks",*fd_count);

	FD_SET(port->fd,fdset);
	io_tasks[fds].port = port;
	io_tasks[fds].callback = callback;
	*fd_count = fds + 1;
}

void add_read_io_task(PORT* port, CELL callback)
{
	add_io_task(port,callback,
		&read_fd_set,read_io_tasks,
		&read_fd_count);
}

void add_write_io_task(PORT* port, CELL callback)
{
	add_io_task(port,callback,
		&write_fd_set,write_io_tasks,
		&write_fd_count);
}

void remove_io_task(
	PORT* port,
	fd_set* fdset,
	IO_TASK* io_tasks,
	int* fd_count)
{
	int i;
	int fds = *fd_count;

	for(i = 0; i < fds; i++)
	{
		if(io_tasks[i].port == port)
		{
			FD_CLR(port->fd,fdset);
			io_tasks[i].port = NULL;
			io_tasks[i].callback = F;
			if(i == fds - 1)
				*fd_count = fds - 1;
			return;
		}
	}
}

void remove_read_io_task(PORT* port)
{
	remove_io_task(port,&read_fd_set,read_io_tasks,&read_fd_count);
}

void remove_write_io_task(PORT* port)
{
	remove_io_task(port,&write_fd_set,write_io_tasks,&write_fd_count);
}

/* Wait for I/O and return a callback. */
CELL iomux(void)
{
	int nfds = select(read_fd_count > write_fd_count
		? read_fd_count : write_fd_count,
		&read_fd_set,&write_fd_set,NULL,NULL);

	return F;
}
