#include "factor.h"

void init_compiler(void)
{
	init_zone(&compiling,COMPILE_ZONE_SIZE);
}

void primitive_compile_byte(void)
{
	bput(compiling.here,to_fixnum(dpop()));
	compiling.here++;
}

void primitive_compile_cell(void)
{
	put(compiling.here,to_cell(dpop()));
	compiling.here += sizeof(CELL);
}

void primitive_compile_offset(void)
{
	dpush(tag_integer(compiling.here));
}
