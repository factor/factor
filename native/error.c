#include "factor.h"

void fatal_error(char* msg, CELL tagged)
{
	printf("Fatal error: %s %ld\n",msg,tagged);
	exit(1);
}

void critical_error(char* msg, CELL tagged)
{
	printf("Critical error: %s %ld\n",msg,tagged);
	save_image("factor.crash.image");
	exit(1);
}

void fix_stacks(void)
{
	if(UNDERFLOW(env.ds,env.ds_bot) || OVERFLOW(env.ds,env.ds_bot))
		reset_datastack();
	if(UNDERFLOW(env.cs,env.cs_bot) || OVERFLOW(env.cs,env.cs_bot))
		reset_callstack();
}

void throw_error(CELL error)
{
	fix_stacks();

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
	CONS* c = cons(error,tag_cons(cons(tagged,F)));
	throw_error(tag_cons(c));
}

void type_error(CELL type, CELL tagged)
{
	CONS* c = cons(tag_fixnum(type),tag_cons(cons(tagged,F)));
	general_error(ERROR_TYPE,tag_cons(c));
}

void range_error(CELL tagged, CELL index, CELL max)
{
	CONS* c = cons(tagged,tag_cons(cons(tag_fixnum(index),
		tag_cons(cons(tag_fixnum(max),F)))));
	general_error(ERROR_RANGE,tag_cons(c));
}

void io_error(const char* func)
{
	STRING* function = from_c_string(func);
	STRING* error = from_c_string(strerror(errno));

	CONS* c = cons(tag_object(function),tag_cons(
		cons(tag_object(error),F)));
	general_error(ERROR_IO,tag_cons(c));
}
