#include "factor.h"

void init_compiler(CELL size)
{
	compiling.base = compiling.here = (CELL)alloc_guarded(size);
	if(compiling.base == 0)
		fatal_error("Cannot allocate code heap",size);
	compiling.limit = compiling.base + size;
	last_flush = compiling.base;
}

void primitive_compiled_offset(void)
{
	box_unsigned_cell(compiling.here);
}

void primitive_set_compiled_offset(void)
{
	CELL offset = unbox_unsigned_cell();
	compiling.here = offset;
}

void primitive_literal_top(void)
{
	box_unsigned_cell(literal_top);
}

void primitive_set_literal_top(void)
{
	CELL offset = unbox_unsigned_cell();
	if(offset >= literal_max)
		critical_error("Too many compiled literals",offset);
	literal_top = offset;
}

void primitive_flush_icache(void)
{
	flush_icache((void*)last_flush,compiling.here - last_flush);
	last_flush = compiling.here;
}

void collect_literals(void)
{
	CELL i;
	for(i = compiling.base; i < literal_top; i += CELLS)
		copy_handle((CELL*)i);
}
