#include "factor.h"

CONS* cons(CELL car, CELL cdr)
{
	CONS* cons = allot(sizeof(CONS));
	cons->car = car;
	cons->cdr = cdr;
	return cons;
}

void primitive_consp(void)
{
	drepl(tag_boolean(typep(CONS_TYPE,dpeek())));
}

void primitive_cons(void)
{
	CELL cdr = dpop();
	CELL car = dpop();
	dpush(tag_cons(cons(car,cdr)));
}

void primitive_car(void)
{
	drepl(car(dpeek()));
}

void primitive_cdr(void)
{
	drepl(cdr(dpeek()));
}

void primitive_set_car(void)
{
	CELL cons = dpop();
	CELL car = dpop();
	untag_cons(cons)->car = car;
}

void primitive_set_cdr(void)
{
	CELL cons = dpop();
	CELL cdr = dpop();
	untag_cons(cons)->cdr = cdr;
}
