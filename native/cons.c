#include "factor.h"

CELL cons(CELL car, CELL cdr)
{
	F_CONS* cons = allot(sizeof(F_CONS));
	cons->car = car;
	cons->cdr = cdr;
	return tag_cons(cons);
}

void primitive_cons(void)
{
	CELL car, cdr;
	maybe_garbage_collection();
	cdr = dpop();
	car = dpop();
	dpush(cons(car,cdr));
}

void primitive_to_cons(void)
{
	type_check(CONS_TYPE,dpeek());
}
