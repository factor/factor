#include "factor.h"

void clear_environment(void)
{
	int i;
	for(i = 0; i < USER_ENV; i++)
		userenv[i] = F;
	profile_depth = 0;
	executing = F;
}

#define EXECUTE(w) ((XT)(untag_word_fast(w)->xt))()

void run(void)
{
	CELL next;

	/* Error handling. */
#ifdef WIN32
	setjmp(toplevel);
	__try
	{
#else
	sigsetjmp(toplevel, 1);
#endif

	if(thrown_error != F)
	{
		if(thrown_keep_stacks)
		{
			ds = thrown_ds;
			cs = thrown_cs;
		}
		else
			fix_stacks();

		dpush(thrown_error);
		/* Notify any 'catch' blocks */
		call(userenv[BREAK_ENV]);
		thrown_error = F;
	}

	for(;;)
	{
		if(callframe == F)
		{
			callframe = cpop();
			cpop();
			continue;
		}

		callframe = (CELL)untag_cons(callframe);
		next = get(callframe);
		callframe = get(callframe + CELLS);

		if(TAG(next) == WORD_TYPE)
		{
			executing = next;
			EXECUTE(executing);
		}
		else
			dpush(next);
	}

#ifdef WIN32
	}
	__except (GetExceptionCode() == EXCEPTION_ACCESS_VIOLATION ?
		EXCEPTION_EXECUTE_HANDLER : EXCEPTION_CONTINUE_SEARCH)
	{
		signal_error(SIGSEGV);
	}
#endif
}

/* XT of deferred words */
void undefined()
{
	general_error(ERROR_UNDEFINED_WORD,executing);
}

/* XT of compound definitions */
void docol(void)
{
	call(untag_word_fast(executing)->parameter);
}

/* pushes word parameter */
void dosym(void)
{
	dpush(untag_word_fast(executing)->parameter);
}

void primitive_execute(void)
{
	type_check(WORD_TYPE,dpeek());
	executing = dpop();
	EXECUTE(executing);
}

void primitive_call(void)
{
	call(dpop());
}

void primitive_ifte(void)
{
	CELL f = dpop();
	CELL t = dpop();
	CELL cond = dpop();
	call(untag_boolean(cond) ? t : f);
}

void primitive_getenv(void)
{
	F_FIXNUM e = to_fixnum(dpeek());
	if(e < 0 || e >= USER_ENV)
		range_error(F,0,tag_fixnum(e),USER_ENV);
	drepl(userenv[e]);
}

void primitive_setenv(void)
{
	F_FIXNUM e = to_fixnum(dpop());
	CELL value = dpop();
	if(e < 0 || e >= USER_ENV)
		range_error(F,0,tag_fixnum(e),USER_ENV);
	userenv[e] = value;
}
