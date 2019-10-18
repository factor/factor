#include "factor.h"

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
			callframe = thrown_callframe;
			executing = thrown_executing;
		}
		else
		{
			fix_stacks();
			callframe = F;
			executing = F;
		}

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
	call(cond == F ? f : t);
}

void primitive_dispatch(void)
{
	F_VECTOR *v = (F_VECTOR*)UNTAG(dpop());
	F_FIXNUM n = untag_fixnum_fast(dpop());
	call(get(AREF(untag_array_fast(v->array),n)));
}

void primitive_getenv(void)
{
	F_FIXNUM e = untag_fixnum_fast(dpeek());
	drepl(userenv[e]);
}

void primitive_setenv(void)
{
	F_FIXNUM e = untag_fixnum_fast(dpop());
	CELL value = dpop();
	userenv[e] = value;
}
