#include "factor.h"

void clear_environment(void)
{
	int i;
	for(i = 0; i < USER_ENV; i++)
		userenv[i] = F;
	profile_depth = 0;
	executing = F;
}

INLINE void execute(F_WORD* word)
{
	((XT)(word->xt))(word);
}

void run(void)
{
	CELL next;

	/* Error handling. */
#ifdef WIN32
	setjmp(toplevel);
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
			executing = cpop();
			continue;
		}

		callframe = (CELL)untag_cons(callframe);
		next = get(callframe);
		callframe = get(callframe + CELLS);

		if(type_of(next) == WORD_TYPE)
			execute(untag_word_fast(next));
		else
			dpush(next);
	}
}

/* XT of deferred words */
void undefined(F_WORD* word)
{
	general_error(ERROR_UNDEFINED_WORD,tag_object(word));
}

/* XT of compound definitions */
void docol(F_WORD* word)
{
	call(word->def);
	executing = tag_object(word);
}

/* pushes word parameter */
void dosym(F_WORD* word)
{
	dpush(word->def);
}

void primitive_execute(void)
{
	execute(untag_word(dpop()));
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
