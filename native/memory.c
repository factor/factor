#include "factor.h"

/* set up guard pages to check for under/overflow.
size must be a multiple of the page size */
void* alloc_guarded(CELL size)
{
	int pagesize = getpagesize();

	char* array = mmap((void*)0,pagesize + size + pagesize,
		PROT_READ | PROT_WRITE,MAP_ANON | MAP_PRIVATE,-1,0);

	if(mprotect(array,pagesize,PROT_NONE) == -1)
		fatal_error("Cannot allocate low guard page",(CELL)array);

	if(mprotect(array + pagesize + size,pagesize,PROT_NONE) == -1)
		fatal_error("Cannot allocate high guard page",(CELL)array);

	/* return bottom of actual array */
	return array + pagesize;
}

ZONE* zalloc(CELL size)
{
	ZONE* z = (ZONE*)malloc(sizeof(ZONE));
	if(z == 0)
		fatal_error("Cannot allocate zone header",size);
	z->base = z->here = (CELL)malloc(size);
	if(z->base == 0)
		fatal_error("Cannot allocate zone",size);
	z->limit = z->base + size;
	z->alarm = z->base + (size * 3) / 4;
	z->base = align8(z->base);
	return z;
}

void init_arena(CELL size)
{
	z1 = zalloc(size);
	z2 = zalloc(size);
	active = z1;
}

void* allot(CELL a)
{
	CELL h = active->here;
	active->here = align8(active->here + a);

	if(active->here > active->limit)
	{
		printf("Out of memory\n");
		printf("active->base  = %ld\n",active->base);
		printf("active->here  = %ld\n",active->here);
		printf("active->limit = %ld\n",active->limit);
		printf("request       = %ld\n",a);
		exit(1);
	}
	else if(active->here > active->alarm)
	{
		/* Execute the 'garbage-collection' word */
		cpush(env.cf);
		env.cf = env.user[GC_ENV];
	}

	return (void*)h;
}

void flip_zones()
{
	if(active == z1)
	{
		prior = z1;
		active = z2;
	}
	else
	{
		prior = z2;
		active = z1;
	}
}

bool in_zone(ZONE* z, CELL pointer)
{
	return pointer >= z->base && pointer < z->limit;
}

void primitive_room(void)
{
	/* push: free total */
	dpush(tag_fixnum(active->limit - active->here));
	dpush(tag_fixnum(active->limit - active->base));
}
