#include "factor.h"

void primitive_wrapper(void)
{
	F_WRAPPER* wrapper;

	maybe_gc(sizeof(F_WRAPPER));

	wrapper = allot_object(WRAPPER_TYPE,sizeof(F_WRAPPER));
	wrapper->object = dpeek();
	drepl(tag_object(wrapper));
}

void fixup_wrapper(F_WRAPPER* wrapper)
{
	data_fixup(&wrapper->object);
}

void collect_wrapper(F_WRAPPER* wrapper)
{
	copy_handle(&wrapper->object);
}
