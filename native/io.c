#include "factor.h"

void init_io_tasks(fd_set* fdset, IO_TASK* io_tasks)
{
	int i;

	FD_ZERO(fdset);
	for(i = 0; i < FD_SETSIZE; i++)
	{
		io_tasks[i].port = F;
		io_tasks[i].callbacks = F;
	}
}

void init_io(void)
{
	userenv[STDIN_ENV]  = tag_object(port(PORT_READ,0));
	userenv[STDOUT_ENV] = tag_object(port(PORT_WRITE,1));
	
	/* debug_fd = fdopen(3,"w"); */

	read_fd_count = 0;
	init_io_tasks(&read_fd_set,read_io_tasks);

	write_fd_count = 0;
	init_io_tasks(&write_fd_set,write_io_tasks);
}

IO_TASK* add_io_task(
	IO_TASK_TYPE type,
	CELL port,
	CELL other_port,
	CELL callback,
	IO_TASK* io_tasks,
	int* fd_count)
{
	int fd = untag_port(port)->fd;

	if(io_tasks[fd].callbacks != F && type != IO_TASK_WRITE)
		general_error(ERROR_IO_TASK_TWICE,port);

	io_tasks[fd].type = type;
	io_tasks[fd].port = port;
	io_tasks[fd].other_port = other_port;
	io_tasks[fd].callbacks = cons(callback,
		io_tasks[fd].callbacks);

	if(fd >= *fd_count)
		*fd_count = fd + 1;

	return &io_tasks[fd];
}

void remove_io_task(
	F_PORT* port,
	IO_TASK* io_tasks,
	int* fd_count)
{
	int fd = port->fd;

	io_tasks[fd].port = F;
	io_tasks[fd].other_port = F;
	io_tasks[fd].callbacks = F;

	if(fd == *fd_count - 1)
		*fd_count = *fd_count - 1;
}

bool perform_copy_from_io_task(F_PORT* port, F_PORT* other_port)
{
	if(port->buf_fill == 0)
	{
		if(read_step(port))
		{
			/* EOF? */
			if(port->buf_fill == 0)
				return true;
		}
		else
			return false;
	}

	if(can_write(other_port,port->buf_fill))
	{
		write_string_raw(other_port,
			(BYTE*)(untag_string(port->buffer) + 1),
			port->buf_fill);
		port->buf_pos = port->buf_fill = 0;
	}

	return false;
}

bool perform_copy_to_io_task(F_PORT* port, F_PORT* other_port)
{
	bool success = perform_write_io_task(port);
	/* only return 'true' if the COPY_FROM task is done also. */
	if(read_io_tasks[other_port->fd].port == F)
		return success;
	else
		return false;
}

void primitive_add_copy_io_task(void)
{
	CELL callback = dpop();
	CELL to = dpop();
	CELL from = dpop();
	/* callback for COPY_FROM is F since we only care about
	when BOTH tasks are done, and this is taken care of by
	COPY_TO. */
	add_io_task(IO_TASK_COPY_FROM,from,to,F,
		read_io_tasks,&read_fd_count);
	add_io_task(IO_TASK_COPY_TO,to,from,callback,
		write_io_tasks,&write_fd_count);
}

/* We set closed to true if there are closed fd's in the set. */
bool set_up_fd_set(fd_set* fdset, int fd_count, IO_TASK* io_tasks,
	bool* closed)
{
	bool retval = false;
	int i;

	FD_ZERO(fdset);

	for(i = 0; i < fd_count; i++)
	{
		if(typep(PORT_TYPE,io_tasks[i].port))
		{
			if(untag_port(io_tasks[i].port)->closed)
				*closed = true;
			retval = true;
			FD_SET(i,fdset);
		}
	}
	
	return retval;
}

CELL pop_io_task_callback(
	IO_TASK_TYPE type,
	F_PORT* port,
	IO_TASK* io_tasks,
	int* fd_count)
{
	int fd = port->fd;
	F_CONS* callbacks = untag_cons(io_tasks[fd].callbacks);
	CELL callback = callbacks->car;
	if(callbacks->cdr == F)
		remove_io_task(port,io_tasks,fd_count);
	else
		io_tasks[fd].callbacks = callbacks->cdr;
	return callback;
}

CELL perform_io_task(IO_TASK* io_task, IO_TASK* io_tasks, int* fd_count)
{
	bool success;
	F_PORT* port = untag_port(io_task->port);

	switch(io_task->type)
	{
	case IO_TASK_READ_LINE:
		success = perform_read_line_io_task(port);
		break;
	case IO_TASK_READ_COUNT:
		success = perform_read_count_io_task(port);
		break;
	case IO_TASK_WRITE:
		success = perform_write_io_task(port);
		break;
	case IO_TASK_ACCEPT:
		success = accept_connection(port);
		break;
	case IO_TASK_COPY_FROM:
		success = perform_copy_from_io_task(port,
			untag_port(io_task->other_port));
		break;
	case IO_TASK_COPY_TO:
		success = perform_copy_to_io_task(port,
			untag_port(io_task->other_port));
		break;
	default:
		critical_error("Bad I/O task",io_task->type);
		success = false;
		break;
	}

	if(success)
	{
		return pop_io_task_callback(io_task->type,port,
			io_tasks,fd_count);
	}
	else
		return F;
}

CELL perform_io_tasks(fd_set* fdset, IO_TASK* io_tasks, int* fd_count)
{
	int i;
	CELL callback;

	for(i = 0; i < *fd_count; i++)
	{
		IO_TASK io_task = io_tasks[i];

		if(typep(PORT_TYPE,io_task.port))
		{
			F_PORT* port = untag_port(io_task.port);
			if(port->closed)
			{
				return pop_io_task_callback(
					io_task.type,port,
					io_tasks,fd_count);
			}
		}

		if(FD_ISSET(i,fdset))
		{
			if(io_task.port == F)
				critical_error("select() returned fd for non-existent task",i);
			else
			{
				callback = perform_io_task(&io_task,
					io_tasks,fd_count);
				if(callback != F)
					return callback;
			}
		}
	}

	return F;
}

/* Wait for I/O and return a callback. */
CELL next_io_task(void)
{
	CELL callback;

	bool closed = false;

	bool reading = set_up_fd_set(&read_fd_set,
		read_fd_count,read_io_tasks,&closed);

	bool writing = set_up_fd_set(&write_fd_set,
		write_fd_count,write_io_tasks,&closed);

	if(!reading && !writing && !closed)
		general_error(ERROR_IO_TASK_NONE,F);

	set_up_fd_set(&except_fd_set,read_fd_count,read_io_tasks,&closed);

	if(!closed)
	{
		select(read_fd_count > write_fd_count
			? read_fd_count : write_fd_count,
			&read_fd_set,&write_fd_set,&except_fd_set,NULL);
	}

	callback = perform_io_tasks(&read_fd_set,
		read_io_tasks,&read_fd_count);

	if(callback != F)
		return callback;

	return perform_io_tasks(&write_fd_set,
		write_io_tasks,&write_fd_count);
}

void primitive_next_io_task(void)
{
	dpush(next_io_task());
}

void primitive_close(void)
{
	/* This does not flush. */
	F_PORT* port = untag_port(dpop());
	close(port->fd);
	port->closed = true;
}

void collect_io_tasks(void)
{
	int i;

	for(i = 0; i < FD_SETSIZE; i++)
	{
		copy_object(&read_io_tasks[i].port);
		copy_object(&read_io_tasks[i].callbacks);
	}

	for(i = 0; i < FD_SETSIZE; i++)
	{
		copy_object(&write_io_tasks[i].port);
		copy_object(&write_io_tasks[i].callbacks);
	}
}
