#include "factor.h"

static ZONE* zalloc(CELL size)
{
	ZONE* z = (ZONE*)malloc(sizeof(ZONE));
	if(z == 0)
		fatal_error("Cannot allocate zone header",size);
	z->base = z->here = (CELL)malloc(size);
	if(z->base == 0)
		fatal_error("Cannot allocate zone",size);
	z->limit = z->base + size;
	z->base = align8(z->base);
	return z;
}

void init_arena(CELL size)
{
	printf("Each semispace is %d bytes\n",size);
	z1 = zalloc(size);
	z2 = zalloc(size);
	active = z1;
}

CELL allot(CELL a)
{
	CELL h = active->here;
	active->here = align8(active->here + a);
	if(active->here > active->limit)
		critical_error("Out of memory",active->here);
	return h;
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
