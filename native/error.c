#include "factor.h"

void init_errors(void)
{
	thrown_error = F;
}

void fatal_error(char* msg, CELL tagged)
{
	fprintf(stderr,"Fatal error: %s %ld\n",msg,tagged);
	exit(1);
}

void critical_error(char* msg, CELL tagged)
{
	fprintf(stderr,"Critical error: %s %ld\n",msg,tagged);
	factorbug();
}

void early_error(CELL error)
{
	if(userenv[BREAK_ENV] == F)
	{
		/* Crash at startup */
		fprintf(stderr,"Error during startup: ");
		print_obj(error);
		fprintf(stderr,"\n");
		factorbug();
	}
}

void throw_error(CELL error, bool keep_stacks)
{
	early_error(error);

	thrown_error = error;
	thrown_keep_stacks = keep_stacks;
	thrown_ds = ds;
	thrown_cs = cs;
	thrown_callframe = callframe;
	thrown_executing = executing;

	/* Return to run() method */
#ifdef WIN32
	longjmp(toplevel,1);
#else
	siglongjmp(toplevel,1);
#endif
}

void primitive_throw(void)
{
	throw_error(dpop(),true);
}

void primitive_die(void)
{
	factorbug();
}

void general_error(CELL error, CELL tagged)
{
	CELL thrown = cons(userenv[ERROR_ENV],cons(error,cons(tagged,F)));
	throw_error(thrown,true);
}

/* It is not safe to access 'ds' from a signal handler, so we just not
touch it */
void signal_error(int signal)
{
	throw_error(cons(userenv[ERROR_ENV],
		cons(ERROR_SIGNAL,
			cons(tag_fixnum(signal),F))),false);
}

void type_error(CELL type, CELL tagged)
{
	CELL c = cons(tag_fixnum(type),cons(tagged,F));
	general_error(ERROR_TYPE,c);
}
