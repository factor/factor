#include "factor.h"

CELL cons(CELL car, CELL cdr)
{
	CONS* cons = (CONS*)allot(sizeof(CONS));
	cons->car = car;
	cons->cdr = cdr;
	return cons;
}

void primitive_consp(void)
{
	switch(TAG(env.dt))
	{
	case EMPTY_TYPE:
		check_non_empty(env.dt);
		break;
	case CONS_TYPE:
		env.dt = T;
		break;
	default:
		env.dt = F;
		break;
	}
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
