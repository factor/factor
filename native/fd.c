#include "factor.h"

void primitive_close_fd(void)
{
	HANDLE* h = untag_handle(HANDLE_FD,env.dt);
	close(h->object);
	env.dt = dpop();
}

void primitive_read_line_fd_8(void)
{
	HANDLE* h = untag_handle(HANDLE_FD,env.dt);
	int fd = h->object;

	/* finished line, unicode */
	SBUF* line = sbuf(LINE_SIZE);

	/* read ascii from fd */
	STRING* buf = string(LINE_SIZE / 2,'\0');

	int amount;
	int i;
	int ch;
	
	for(;;)
	{
		amount = read(fd,buf + 1,buf->capacity * 2);
		if(amount <= 0) /* error or EOF */
			goto end;
		else
		{
			for(i = 0; i < amount; i++)
			{
				ch = bget((CELL)buf + sizeof(STRING) + i);
				if(ch == '\n')
					goto end;
				else
					set_sbuf_nth(line,line->top,ch);
			}
		}
	}

end:	env.dt = tag_object(line);
}

void primitive_write_fd_8(void)
{
	HANDLE* h = untag_handle(HANDLE_FD,env.dt);
	int fd = h->object;
	STRING* str = untag_string(dpop());
	char* c_str = to_c_string(str);
	write(fd,c_str,str->capacity);
	env.dt = dpop();
}

void primitive_flush_fd(void)
{
	HANDLE* h = untag_handle(HANDLE_FD,env.dt);
	int fd = h->object;
	fsync(fd);
	env.dt = dpop();
}
