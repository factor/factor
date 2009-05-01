#include "master.h"

/* FFI calls this */
void box_boolean(bool value)
{
	dpush(value ? T : F);
}

/* FFI calls this */
bool to_boolean(CELL value)
{
	return value != F;
}
