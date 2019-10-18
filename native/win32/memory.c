#include "../factor.h"

void *alloc_guarded(CELL size)
{
       SYSTEM_INFO si;
       char *mem;
       DWORD ignore;

       GetSystemInfo(&si);
       mem = (char *)VirtualAlloc(NULL, si.dwPageSize*2 + size, MEM_COMMIT, PAGE_EXECUTE_READWRITE);

       if (!VirtualProtect(mem, si.dwPageSize, PAGE_NOACCESS, &ignore))
	       fatal_error("Cannot allocate low guard page", (CELL)mem);

       if (!VirtualProtect(mem+size+si.dwPageSize, si.dwPageSize, PAGE_NOACCESS, &ignore))
	       fatal_error("Cannot allocate high guard page", (CELL)mem);

       return mem + si.dwPageSize;
}
