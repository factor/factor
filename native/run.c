#include "factor.h"

INLINE void execute(F_WORD* word)
{
	((XT)(word->xt))(word);
}

void call(CELL quot)
{
	F_ARRAY *untagged;

	if(quot == F)
		return;

	type_check(QUOTATION_TYPE,quot);

	/* tail call optimization */
	if(callframe_scan < callframe_end)
	{
		put(cs + CELLS,callframe);
		put(cs + CELLS * 2,callframe_scan);
		put(cs + CELLS * 3,callframe_end);
		cs += CELLS * 3;
	}

	callframe = quot;
	untagged = (F_ARRAY*)UNTAG(quot);
	callframe_scan = AREF(untagged,0);
	callframe_end = AREF(untagged,array_capacity(untagged));
}

/* Called from platform_run() */
void handle_error(void)
{
	if(throwing)
	{
		if(thrown_keep_stacks)
		{
			ds = thrown_ds;
			rs = thrown_rs;
		}
		else
			fix_stacks();

		dpush(thrown_error);
		/* Notify any 'catch' blocks */
		call(userenv[BREAK_ENV]);
		throwing = false;
	}
}

void run(void)
{
	CELL next;

	for(;;)
	{
		if(callframe_scan == callframe_end)
		{
			if(cs_bot - cs == CELLS)
				return;

			callframe_end = get(cs);
			callframe_scan = get(cs - CELLS);
			callframe = get(cs - CELLS * 2);
			cs -= CELLS * 3;
			continue;
		}

		next = get(callframe_scan);
		callframe_scan += CELLS;

		switch(type_of(next))
		{
		case WORD_TYPE:
			execute(untag_word_fast(next));
			break;
		case WRAPPER_TYPE:
			dpush(untag_wrapper_fast(next)->object);
			break;
		default:
			dpush(next);
			break;
		}
	}
}

void run_toplevel(void)
{
	SETJMP(stack_chain->toplevel);
	handle_error();
	run();
}

/* Called by compiled callbacks after nest_stacks() and boxing registers */
void run_callback(CELL quot)
{
	call(quot);
	platform_run();
}

/* XT of deferred words */
void undefined(F_WORD* word)
{
	general_error(ERROR_UNDEFINED_WORD,tag_object(word),F,true);
}

/* XT of compound definitions */
void docol(F_WORD* word)
{
	call(word->def);
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
	F_ARRAY *a = untag_array_fast(dpop());
	F_FIXNUM n = untag_fixnum_fast(dpop());
	call(get(AREF(a,n)));
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
