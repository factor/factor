#include "../factor.h"

BOUNDED_BLOCK *alloc_bounded_block(CELL size)
{
	int pagesize = getpagesize();

	char *array = mmap((void*)0,pagesize + size + pagesize,
		PROT_READ | PROT_WRITE | PROT_EXEC,
		MAP_ANON | MAP_PRIVATE,-1,0);

	if(array == NULL)
		fatal_error("Cannot allocate memory region",0);

	if(mprotect(array,pagesize,PROT_NONE) == -1)
		fatal_error("Cannot protect low guard page",(CELL)array);

	if(mprotect(array + pagesize + size,pagesize,PROT_NONE) == -1)
		fatal_error("Cannot protect high guard page",(CELL)array);

	BOUNDED_BLOCK *retval = malloc(sizeof(BOUNDED_BLOCK));
	if(retval == NULL)
		fatal_error("Cannot allocate BOUNDED_BLOCK struct",0);
	
	retval->start = (CELL)(array + pagesize);
	retval->size = size;

	return retval;
}

void dealloc_bounded_block(BOUNDED_BLOCK *block)
{
	int pagesize = getpagesize();

	int retval = munmap((void*)(block->start - pagesize),
		pagesize + block->size + pagesize);
	
	if(retval)
		fatal_error("Failed to unmap region",0);

	free(block);
}
