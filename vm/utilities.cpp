#include "master.hpp"

namespace factor
{

/* If memory allocation fails, bail out */
void *safe_malloc(size_t size)
{
	void *ptr = malloc(size);
	if(!ptr) fatal_error("Out of memory in safe_malloc", 0);
	return ptr;
}

vm_char *safe_strdup(const vm_char *str)
{
	vm_char *ptr = STRDUP(str);
	if(!ptr) fatal_error("Out of memory in safe_strdup", 0);
	return ptr;
}

/* We don't use printf directly, because format directives are not portable.
Instead we define the common cases here. */
void nl()
{
	fputs("\n",stdout);
}

void print_string(const char *str)
{
	fputs(str,stdout);
}

void print_cell(cell x)
{
	printf(cell_FORMAT,x);
}

void print_cell_hex(cell x)
{
	printf(cell_HEX_FORMAT,x);
}

void print_cell_hex_pad(cell x)
{
	printf(cell_HEX_PAD_FORMAT,x);
}

void print_fixnum(fixnum x)
{
	printf(FIXNUM_FORMAT,x);
}

cell read_cell_hex()
{
	cell cell;
	if(scanf(cell_HEX_FORMAT,&cell) < 0) exit(1);
	return cell;
};

}
