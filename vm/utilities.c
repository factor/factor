#include "master.h"

/* If memory allocation fails, bail out */
void *safe_malloc(size_t size)
{
	void *ptr = malloc(size);
	if(!ptr) fatal_error("Out of memory in safe_malloc", 0);
	return ptr;
}

F_CHAR *safe_strdup(const F_CHAR *str)
{
	F_CHAR *ptr = STRDUP(str);
	if(!ptr) fatal_error("Out of memory in safe_strdup", 0);
	return ptr;
}

/* We don't use printf directly, because format directives are not portable.
Instead we define the common cases here. */
void nl(void)
{
	fputs("\n",stdout);
}

void print_string(const char *str)
{
	fputs(str,stdout);
}

void print_cell(CELL x)
{
	printf(CELL_FORMAT,x);
}

void print_cell_hex(CELL x)
{
	printf(CELL_HEX_FORMAT,x);
}

void print_cell_hex_pad(CELL x)
{
	printf(CELL_HEX_PAD_FORMAT,x);
}

void print_fixnum(F_FIXNUM x)
{
	printf(FIXNUM_FORMAT,x);
}

CELL read_cell_hex(void)
{
	CELL cell;
	if(scanf(CELL_HEX_FORMAT,&cell) < 0) exit(1);
	return cell;
};
