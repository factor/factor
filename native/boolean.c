#include "factor.h"

/* FFI calls this */
void box_boolean(bool value)
{
	dpush(value ? T : F);
}

/* FFI calls this */
bool unbox_boolean(void)
{
	return (dpop() != F);
}
