#include "factor.h"

void fatal_error(char* msg, CELL tagged)
{
	fprintf(stderr,"Fatal error: %s %ld\n",msg,tagged);
	exit(1);
}

void critical_error(char* msg, CELL tagged)
{
	fprintf(stderr,"Critical error: %s %ld\n",msg,tagged);
	save_image("factor.crash.image");
	exit(1);
}

void fix_stacks(void)
{
	if(STACK_UNDERFLOW(ds,ds_bot)
		|| STACK_OVERFLOW(ds,ds_bot))
		reset_datastack();
	if(STACK_UNDERFLOW(cs,cs_bot)
		|| STACK_OVERFLOW(cs,cs_bot))
		reset_callstack();
}

void throw_error(CELL error)
{
	fix_stacks();

	dpush(error);
	/* Execute the 'throw' word */
	call(userenv[BREAK_ENV]);

	/* Return to run() method */
	siglongjmp(toplevel,1);
}

void general_error(CELL error, CELL tagged)
{
	CELL c = cons(error,cons(tagged,F));
	if(userenv[BREAK_ENV] == 0)
	{
		/* Crash at startup */
		fprintf(stderr,"Error thrown before BREAK_ENV set\n");
		fprintf(stderr,"Error #%ld\n",to_fixnum(error));
		if(error == ERROR_TYPE)
		{
			CELL obj = untag_cons(untag_cons(tagged)->cdr)->car;

			fprintf(stderr,"Type #%ld\n",to_fixnum(
				untag_cons(tagged)->car));
			fprintf(stderr,"Object %ld\n",obj);
			fprintf(stderr,"Got type #%ld\n",type_of(obj));
		}
		fflush(stderr);
		exit(1);
	}
	throw_error(c);
}

void type_error(CELL type, CELL tagged)
{
	CELL c = cons(tag_fixnum(type),cons(tagged,F));
	general_error(ERROR_TYPE,c);
}

void range_error(CELL tagged, CELL index, CELL max)
{
	CELL c = cons(tagged,cons(tag_fixnum(index),cons(tag_fixnum(max),F)));
	general_error(ERROR_RANGE,c);
}
