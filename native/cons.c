#include "factor.h"

CONS* cons(CELL car, CELL cdr)
{
	CONS* cons = (CONS*)allot(sizeof(CONS));
	cons->car = car;
	cons->cdr = cdr;
	return cons;
}

void primitive_consp(void)
{
	check_non_empty(env.dt);
	env.dt = tag_boolean(typep(CONS_TYPE,env.dt));
}

void primitive_cons(void)
{
	check_non_empty(env.dt);
	check_non_empty(dpeek());
	env.dt = tag_cons(cons(dpop(),env.dt));
}

void primitive_car(void)
{
	env.dt = car(env.dt);
}

void primitive_cdr(void)
{
	env.dt = cdr(env.dt);
}

void primitive_rplaca(void)
{
	check_non_empty(dpeek());
	untag_cons(env.dt)->car = dpop();
	env.dt = dpop();
}

void primitive_rplacd(void)
{
	check_non_empty(dpeek());
	untag_cons(env.dt)->cdr = dpop();
	env.dt = dpop();
}
