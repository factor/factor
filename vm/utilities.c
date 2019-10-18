#include "master.h"

/* If memory allocation fails, bail out */
void *safe_malloc(size_t size)
{
	void *ptr = malloc(size);
	if(!ptr) fatal_error("Out of memory in safe_malloc", 0);
	return ptr;
}

void *safe_realloc(const void *ptr, size_t size)
{
	void *new_ptr = realloc((void *)ptr,size);
	if(!new_ptr) fatal_error("Out of memory in safe_realloc", 0);
	return new_ptr;
}

F_CHAR *safe_strdup(const F_CHAR *str)
{
	F_CHAR *ptr = STRDUP(str);
	if(!ptr) fatal_error("Out of memory in safe_strdup", 0);
	return ptr;
}
