#include "../factor.h"

BOUNDED_BLOCK *alloc_bounded_block(CELL size)
{
	SYSTEM_INFO si;
	char *mem;
	DWORD ignore;
	
	GetSystemInfo(&si);
	mem = (char *)VirtualAlloc(NULL, si.dwPageSize*2 + size, MEM_COMMIT, PAGE_EXECUTE_READWRITE);
	if(!mem)
		fatal_error("VirtualAlloc() failed in alloc_bounded_block()",0);
	
	if (!VirtualProtect(mem, si.dwPageSize, PAGE_NOACCESS, &ignore))
		fatal_error("Cannot allocate low guard page", (CELL)mem);
	
	if (!VirtualProtect(mem+size+si.dwPageSize, si.dwPageSize, PAGE_NOACCESS, &ignore))
		fatal_error("Cannot allocate high guard page", (CELL)mem);
	
	BOUNDED_BLOCK *retval = safe_malloc(sizeof(BOUNDED_BLOCK));
	
	retval->start = mem + si.dwPageSize;
	retval->size = size;
	
	return retval;
}

void dealloc_bounded_block(BOUNDED_BLOCK *block)
{
	
	SYSTEM_INFO si;
	GetSystemInfo(&si);
	if(!VirtualFree(block->start - si.dwPageSize, si.dwPageSize*2 + block->size, MEM_DECOMMIT))
		fatal_error("VirtualFree() failed",0);
	free(block);
}
