#include "factor.h"

HANDLE* untag_handle(CELL type, CELL tagged)
{
	HANDLE* h;
	type_check(HANDLE_TYPE,tagged);
	h = (HANDLE*)UNTAG(tagged);
	/* after image load & save, handles are no longer valid */
	if(h->object == 0)
		general_error(ERROR_HANDLE_EXPIRED,tagged);
	if(h->type != type)
		general_error(ERROR_HANDLE_INCOMPAT,tagged);
	return h;
}

CELL handle(CELL type, CELL object)
{
	HANDLE* handle = (HANDLE*)allot_object(HANDLE_TYPE,sizeof(HANDLE));
	handle->type = type;
	handle->object = object;
	return tag_object(handle);
}

void primitive_handlep(void)
{
	check_non_empty(env.dt);
	env.dt = tag_boolean(typep(HANDLE_TYPE,env.dt));
}
