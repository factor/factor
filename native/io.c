#include "factor.h"

void init_io(void)
{
	env.user[STDIN_ENV]  = handle(HANDLE_FD,0);
	env.user[STDOUT_ENV] = handle(HANDLE_FD,1);
	env.user[STDERR_ENV] = handle(HANDLE_FD,2);
}

void primitive_open_file(void)
{
	char* mode = to_c_string(untag_string(env.dt));
	char* path = to_c_string(untag_string(dpop()));
	FILE* file = fopen(path,mode);
	env.dt = handle(HANDLE_C_STREAM,file);
}

/* read a line of ASCII text. */
void primitive_read_line_8(void)
{
	HANDLE* h = untag_handle(HANDLE_C_STREAM,env.dt);
	FILE* file = (FILE*)h->object;

	SBUF* b = sbuf(LINE_SIZE);

	int ch;
	
	for(;;)
	{
		ch = getc(file);
		if(ch == EOF)
		{
			if(b->top == 0)
			{
				/* EOF and no input -- return f. */
				env.dt = F;
				return;
			}
			else
				break;
		}
		else if(ch == '\n')
			break;
		else
			set_sbuf_nth(b,b->top,ch);
	}

	env.dt = tag_object(b);
}

/* write a string. */
void primitive_write_8(void)
{
	HANDLE* h = untag_handle(HANDLE_C_STREAM,env.dt);
	FILE* file = (FILE*)h->object;
	STRING* str = untag_string(dpop());
	CELL strlen = str->capacity;
	int i;

	env.dt = dpop();

	for(i = 0; i < strlen; i++)
		putc(string_nth(str,i),file);
}

void primitive_close(void)
{
	HANDLE* h = untag_handle(HANDLE_C_STREAM,env.dt);
	fclose((FILE*)h->object);
	env.dt = dpop();
}

void primitive_flush(void)
{
	HANDLE* h = untag_handle(HANDLE_C_STREAM,env.dt);
	fflush((FILE*)h->object);
	env.dt = dpop();
}
