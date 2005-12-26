#include "factor.h"

F_SBUF* sbuf(F_FIXNUM capacity)
{
	F_SBUF* sbuf;
	if(capacity < 0)
		general_error(ERROR_NEGATIVE_ARRAY_SIZE,tag_integer(capacity));
	sbuf = allot_object(SBUF_TYPE,sizeof(F_SBUF));
	sbuf->top = tag_fixnum(0);
	sbuf->string = tag_object(string(capacity,'\0'));
	return sbuf;
}

void primitive_sbuf(void)
{
	CELL size = to_fixnum(dpeek());
	maybe_gc(sizeof(F_SBUF) + string_size(size));
	drepl(tag_object(sbuf(size)));
}

void fixup_sbuf(F_SBUF* sbuf)
{
	data_fixup(&sbuf->string);
}

void collect_sbuf(F_SBUF* sbuf)
{
	copy_handle(&sbuf->string);
}
