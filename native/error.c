#include "factor.h"

void fatal_error(char* msg, CELL tagged)
{
	printf("Fatal error: %s %d\n",msg,tagged);
	exit(1);
}

void throw_error(CELL error)
{
	dpush(env.dt);
	env.dt = error;
	/* Execute the 'throw' word */
	cpush(env.cf);
	env.cf = env.user[BREAK_ENV];
	/* Return to run() method */
	longjmp(toplevel,1);
}

void general_error(CELL error, CELL tagged)
{
	CONS* c = cons(error,tag_cons(
		cons(tagged,F)));
	throw_error(tag_cons(c));
}

void type_error(CELL type, CELL tagged)
{
	CONS* c = cons(type,tag_cons(cons(tagged,F)));
	general_error(ERROR_TYPE,tag_cons(c));
}

void range_error(CELL tagged, CELL index, CELL max)
{
	CONS* c = cons(tagged,tag_cons(cons(tag_fixnum(index),
		tag_cons(cons(tag_fixnum(max),F)))));
	general_error(ERROR_RANGE,c);
}
