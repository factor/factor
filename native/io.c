#include "factor.h"

void init_io(void)
{
	env.user[STDIN_ENV]  = handle(stdin);
	env.user[STDOUT_ENV] = handle(stdout);
	env.user[STDERR_ENV] = handle(stderr);
}

#define LINE_SIZE 80

/* read a line of ASCII text. */
void primitive_read_line_8(void)
{
	HANDLE* h = untag_handle(env.dt);
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

	env.dt = tag_object(sbuf_to_string(b));
}

/* write a string. */
void primitive_write_8(void)
{
	HANDLE* h = untag_handle(env.dt);
	FILE* file = (FILE*)h->object;
	STRING* str = untag_string(dpop());
	CELL strlen = str->capacity;
	int i;

	env.dt = dpop();

	for(i = 0; i < strlen; i++)
		putc(string_nth(str,i),file);
}
