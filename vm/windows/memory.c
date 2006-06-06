#include "../factor.h"

BOUNDED_BLOCK *alloc_bounded_block(CELL size)
{
    SYSTEM_INFO si;
    char *mem;
    DWORD ignore;

    GetSystemInfo(&si);
    if((mem = (char *)VirtualAlloc(NULL, si.dwPageSize*2 + size, MEM_COMMIT, PAGE_EXECUTE_READWRITE)) == 0)
        fatal_error("VirtualAlloc() failed in alloc_bounded_block()",0);

    if (!VirtualProtect(mem, si.dwPageSize, PAGE_NOACCESS, &ignore))
        fatal_error("Cannot allocate low guard page", (CELL)mem);

    if (!VirtualProtect(mem+size+si.dwPageSize, si.dwPageSize, PAGE_NOACCESS, &ignore))
        fatal_error("Cannot allocate high guard page", (CELL)mem);

    BOUNDED_BLOCK *block = safe_malloc(sizeof(BOUNDED_BLOCK));

    block->start = (int)mem + si.dwPageSize;
    block->size = size;

    return block;
}

void dealloc_bounded_block(BOUNDED_BLOCK *block)
{
    SYSTEM_INFO si;
    GetSystemInfo(&si);
    if(!VirtualFree((void*)(block->start - si.dwPageSize), 0, MEM_RELEASE))
        fatal_error("VirtualFree() failed",0);
    free(block);
}

