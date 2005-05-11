#include "../factor.h"

void *alloc_guarded(CELL size)
{
	int pagesize = getpagesize();

	char* array = mmap((void*)0,pagesize + size + pagesize,
		PROT_READ | PROT_WRITE | PROT_EXEC,
		MAP_ANON | MAP_PRIVATE,-1,0);

	if(mprotect(array,pagesize,PROT_NONE) == -1)
		fatal_error("Cannot allocate low guard page",(CELL)array);

	if(mprotect(array + pagesize + size,pagesize,PROT_NONE) == -1)
		fatal_error("Cannot allocate high guard page",(CELL)array);

	/* return bottom of actual array */
	return array + pagesize;
}
