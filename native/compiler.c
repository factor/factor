#include "factor.h"

void init_compiler(void)
{
	init_zone(&compiling,COMPILE_ZONE_SIZE);
	literal_top = compiling.base;
}

void check_compiled_offset(CELL offset)
{
	if(offset < compiling.base || offset >= compiling.limit)
		range_error(F,offset,compiling.limit);
}

void primitive_set_compiled_byte(void)
{
	CELL offset = unbox_integer();
	BYTE b = to_fixnum(dpop());
	check_compiled_offset(offset);
	bput(offset,b);
}

void primitive_set_compiled_cell(void)
{
	CELL offset = unbox_integer();
	CELL c = to_fixnum(dpop());
	check_compiled_offset(offset);
	put(offset,c);
}

void primitive_compiled_offset(void)
{
	box_integer(compiling.here);
}

void primitive_set_compiled_offset(void)
{
	CELL offset = unbox_integer();
	check_compiled_offset(offset);
	compiling.here = offset;
}

void primitive_literal_top(void)
{
	box_integer(literal_top);
}

void primitive_set_literal_top(void)
{
	CELL offset = unbox_integer();
	check_compiled_offset(offset);
	literal_top = offset;
}

void collect_literals(void)
{
	CELL i = compiling.base;
	while(i < literal_top)
	{
		copy_object((CELL*)i);
		i += CELLS;
	}
}
