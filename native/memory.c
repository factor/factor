#include "factor.h"

/* set up guard pages to check for under/overflow.
size must be a multiple of the page size */
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
	allot_profiling = false;
	gc_in_progress = false;
}

#ifdef FACTOR_PROFILER
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
		if(TAG(obj) == WORD_TYPE)
			untag_word(obj)->allot_count += a;
	}

	executing->allot_count += a;
}
#endif

void check_memory(void)
{
	if(active.here > active.alarm)
	{
		if(active.here > active.limit)
		{
			fprintf(stderr,"Out of memory\n");
			fprintf(stderr,"active.base  = %ld\n",active.base);
			fprintf(stderr,"active.here  = %ld\n",active.here);
			fprintf(stderr,"active.limit = %ld\n",active.limit);
			fflush(stderr);
			exit(1);
		}

		/* Execute the 'garbage-collection' word */
		call(userenv[GC_ENV]);
	}
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
	/* push: free total */
	dpush(tag_integer(active.limit - active.here));
	dpush(tag_integer(active.limit - active.base));
}

void primitive_allot_profiling(void)
{
#ifndef FACTOR_PROFILER
	general_error(ERROR_PROFILING_DISABLED,F);
#else
	CELL d = dpop();
	if(d == F)
		allot_profiling = false;
	else
	{
		allot_profiling = true;
		profile_depth = to_fixnum(d);
	}
#endif
}

void primitive_address_of(void)
{
	dpush(tag_object(s48_ulong_to_bignum(dpop())));
}
