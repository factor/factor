#include "factor.h"

void init_compiler(void)
{
	init_zone(&compiling,COMPILE_ZONE_SIZE);
	literal_top = compiling.base;
}

void primitive_compiled_offset(void)
{
	box_integer(compiling.here);
}

void primitive_set_compiled_offset(void)
{
	CELL offset = unbox_integer();
	compiling.here = offset;
}

void primitive_literal_top(void)
{
	box_integer(literal_top);
}

void primitive_set_literal_top(void)
{
	CELL offset = unbox_integer();
	literal_top = offset;
}

void collect_literals(void)
{
	CELL i;
	for(i = compiling.base; i < literal_top; i += CELLS)
		copy_object((CELL*)i);
}
