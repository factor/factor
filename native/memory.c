#include "factor.h"

/* set up guard pages to check for under/overflow.
size must be a multiple of the page size */

#ifdef WIN32
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
#else
void* alloc_guarded(CELL size)
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
#endif

void init_zone(ZONE* z, CELL size)
{
	z->base = z->here = align8((CELL)alloc_guarded(size));
	if(z->base == 0)
		fatal_error("Cannot allocate zone",size);
	z->limit = z->base + size;
	z->alarm = z->base + (size * 3) / 4;
	z->base = align8(z->base);
}

void init_arena(CELL size)
{
	init_zone(&active,size);
	init_zone(&prior,size);
	init_zone(&compiling,size);
	allot_profiling = false;
	gc_in_progress = false;
	gc_time = 0;
}

void allot_profile_step(CELL a)
{
	CELL depth = (cs - cs_bot) / CELLS;
	int i;
	CELL obj;

	if(gc_in_progress)
		return;

	for(i = profile_depth; i < depth; i++)
	{
		obj = get(cs_bot + i * CELLS);
		if(type_of(obj) == WORD_TYPE)
			untag_word(obj)->allot_count += a;
	}

	if(in_zone(&prior,executing))
		critical_error("executing in prior zone",executing);
	untag_word_fast(executing)->allot_count += a;
}

void flip_zones()
{
	ZONE z = active;
	active = prior;
	prior = z;
}

bool in_zone(ZONE* z, CELL pointer)
{
	return pointer >= z->base && pointer < z->limit;
}

void primitive_room(void)
{
	box_integer(compiling.limit - compiling.here);
	box_integer(compiling.limit - compiling.base);
	box_integer(active.limit - active.here);
	box_integer(active.limit - active.base);
}

void primitive_allot_profiling(void)
{
	CELL d = dpop();
	if(d == F)
		allot_profiling = false;
	else
	{
		allot_profiling = true;
		profile_depth = to_fixnum(d);
	}
}

void primitive_address(void)
{
	dpush(tag_object(s48_ulong_to_bignum(dpop())));
}

void primitive_heap_stats(void)
{
	int instances[TYPE_COUNT], bytes[TYPE_COUNT];
	int i;
	CELL ptr;
	CELL list = F;

	for(i = 0; i < TYPE_COUNT; i++)
		instances[i] = 0;

	for(i = 0; i < TYPE_COUNT; i++)
		bytes[i] = 0;

	ptr = active.base;
	while(ptr < active.here)
	{
		CELL value = get(ptr);
		CELL size;
		CELL type;

		if(headerp(value))
		{
			size = align8(untagged_object_size(ptr));
			type = untag_header(value);
		}
		else
		{
			size = CELLS * 2;
			type = CONS_TYPE;
		}

		instances[type]++;
		bytes[type] += size;
		ptr += size;
	}

	for(i = TYPE_COUNT - 1; i >= 0; i--)
	{
		list = cons(
			cons(tag_fixnum(instances[i]),tag_fixnum(bytes[i])),
			list);
	}

	dpush(list);
}
