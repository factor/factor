#include "factor.h"

void init_compiler(CELL size)
{
	compiling.base = compiling.here = (CELL)(alloc_bounded_block(size)->start);
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
	if(compiling.here >= compiling.limit)
	{
		fprintf(stderr,"Code space exhausted\n");
		factorbug();
	}
}

void primitive_add_literal(void)
{
	CELL object = dpeek();
	CELL offset = literal_top;
	put(literal_top,object);
	literal_top += CELLS;
	if(literal_top >= literal_max)
		critical_error("Too many compiled literals",literal_top);
	drepl(tag_cell(offset));
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
