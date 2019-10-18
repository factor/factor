#include "factor.h"

INLINE void execute(F_WORD* word)
{
	((XT)(word->xt))(word);
}

INLINE void push_callframe(void)
{
	put(cs + CELLS,callframe);
	put(cs + CELLS * 2,callframe_scan);
	put(cs + CELLS * 3,callframe_end);

	/* update the pointer last, so that if we have a memory protection error
	above, we don't have garbage stored as live data */
	cs += CELLS * 3;
}

INLINE void set_callframe(CELL quot)
{
	F_ARRAY *untagged = (F_ARRAY*)UNTAG(quot);
	type_check(QUOTATION_TYPE,quot);
	callframe = quot;
	callframe_scan = AREF(untagged,0);
	callframe_end = AREF(untagged,array_capacity(untagged));
}

void call(CELL quot)
{
	if(quot == F)
		return;

	/* tail call optimization */
	if(callframe_scan < callframe_end)
		push_callframe();

	set_callframe(quot);
}

/* Called from interpreter() */
void handle_error(void)
{
	if(throwing)
	{
		gc_off = false;
		extra_roots = stack_chain->extra_roots;

		if(thrown_keep_stacks)
		{
			ds = thrown_ds;
			rs = thrown_rs;
		}
		else
			fix_stacks();

		dpush(thrown_error);
		dpush(thrown_native_stack_trace);
		/* Notify any 'catch' blocks */
		push_callframe();
		set_callframe(userenv[BREAK_ENV]);
		throwing = false;
	}
}

void interpreter_loop(void)
{
	CELL next;

	for(;;)
	{
		if(callframe_scan == callframe_end)
		{
			if(cs_bot - cs == CELLS)
			{
				if(stack_chain->next)
					return;

				simple_error(ERROR_CS_UNDERFLOW,F,F);
			}

			callframe_end = get(cs);
			callframe_scan = get(cs - CELLS);
			callframe = get(cs - CELLS * 2);
			cs -= CELLS * 3;
			continue;
		}

		next = get(callframe_scan);
		callframe_scan += CELLS;

		switch(TAG(next))
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

void interpreter(void)
{
	stack_chain->native_stack_pointer = native_stack_pointer();
	SETJMP(stack_chain->toplevel);
	handle_error();
	interpreter_loop();
}

/* Called by compiled callbacks after nest_stacks() and boxing registers */
void run_callback(CELL quot)
{
	call(quot);
	run();
}

/* XT of deferred words */
void undefined(F_WORD* word)
{
	simple_error(ERROR_UNDEFINED_WORD,tag_word(word),F);
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
	ds -= CELLS * 3;
	call(get(ds + CELLS) == F ? get(ds + CELLS * 3) : get(ds + CELLS * 2));
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

void primitive_exit(void)
{
	exit(unbox_signed_cell());
}

void primitive_os_env(void)
{
	char *name = unbox_char_string();
	char *value = getenv(name);
	if(value == NULL)
		dpush(F);
	else
		box_char_string(value);
}

void primitive_eq(void)
{
	CELL lhs = dpop();
	CELL rhs = dpeek();
	drepl((lhs == rhs) ? T : F);
}

void primitive_millis(void)
{
	box_unsigned_8(current_millis());
}

void primitive_type(void)
{
	drepl(tag_fixnum(type_of(dpeek())));
}

void primitive_tag(void)
{
	drepl(tag_fixnum(TAG(dpeek())));
}

void primitive_slot(void)
{
	F_FIXNUM slot = untag_fixnum_fast(dpop());
	CELL obj = UNTAG(dpop());
	dpush(get(SLOT(obj,slot)));
}

void primitive_set_slot(void)
{
	F_FIXNUM slot = untag_fixnum_fast(dpop());
	CELL obj = UNTAG(dpop());
	CELL value = dpop();
	set_slot(obj,slot,value);
}

void primitive_clone(void)
{
	CELL size = object_size(dpeek());
	void *new_obj = allot(size);
	CELL tag = TAG(dpeek());
	memcpy(new_obj,(void*)UNTAG(dpeek()),size);
	drepl(RETAG(new_obj,tag));
}

void fatal_error(char* msg, CELL tagged)
{
	fprintf(stderr,"Fatal error: %s %lx\n",msg,tagged);
	exit(1);
}

void critical_error(char* msg, CELL tagged)
{
	fprintf(stderr,"Critical error: %s %lx\n",msg,tagged);
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

/* allocates memory */
CELL allot_native_stack_trace(F_STACK_FRAME *stack)
{
	GROWABLE_ARRAY(array);

	while(stack < stack_chain->native_stack_pointer)
	{
		CELL return_address = RETURN_ADDRESS(stack);

		if(return_address >= compiling.base
			&& return_address <= compiling.limit)
		{
			REGISTER_ARRAY(array);
			CELL cell = allot_cell(return_address);
			UNREGISTER_ARRAY(array);
			GROWABLE_ADD(array,cell);
		}

		F_STACK_FRAME *prev = PREVIOUS_FRAME(stack);

		if(prev <= stack)
		{
			fprintf(stderr,"*** Unusual C stack layout (why?)\n");
			fflush(stderr);
			break;
		}

		stack = prev;
	}

	GROWABLE_TRIM(array);

	return tag_object(array);
}

void throw_error(CELL error, bool keep_stacks, F_STACK_FRAME *native_stack)
{
	early_error(error);

	REGISTER_ROOT(error);
	thrown_native_stack_trace = allot_native_stack_trace(native_stack);
	UNREGISTER_ROOT(error);

	throwing = true;
	thrown_error = error;
	thrown_keep_stacks = keep_stacks;
	thrown_ds = ds;
	thrown_rs = rs;

	/* Return to interpreter() function */
	LONGJMP(stack_chain->toplevel,1);
}

void primitive_throw(void)
{
	throw_error(dpop(),true,native_stack_pointer());
}

void primitive_die(void)
{
	factorbug();
}

void general_error(F_ERRORTYPE error, CELL arg1, CELL arg2,
	bool keep_stacks, F_STACK_FRAME *native_stack)
{
	throw_error(allot_array_4(userenv[ERROR_ENV],
		tag_fixnum(error),arg1,arg2),keep_stacks,native_stack);
}

void simple_error(F_ERRORTYPE error, CELL arg1, CELL arg2)
{
	general_error(error,arg1,arg2,true,native_stack_pointer());
}

void memory_protection_error(CELL addr, int signal, F_STACK_FRAME *native_stack)
{
	gc_off = true;

	if(in_page(addr, ds_bot, 0, -1))
		general_error(ERROR_DS_UNDERFLOW,F,F,false,native_stack);
	else if(in_page(addr, ds_bot, ds_size, 0))
		general_error(ERROR_DS_OVERFLOW,F,F,false,native_stack);
	else if(in_page(addr, rs_bot, 0, -1))
		general_error(ERROR_RS_UNDERFLOW,F,F,false,native_stack);
	else if(in_page(addr, rs_bot, rs_size, 0))
		general_error(ERROR_RS_OVERFLOW,F,F,false,native_stack);
	else if(in_page(addr, cs_bot, 0, -1))
		general_error(ERROR_CS_UNDERFLOW,F,F,false,native_stack);
	else if(in_page(addr, cs_bot, cs_size, 0))
		general_error(ERROR_CS_OVERFLOW,F,F,false,native_stack);
	else if(in_page(addr, nursery.limit, 0, 0))
		critical_error("Out of memory in allot",0);

	signal_error(signal,native_stack);
}

void signal_error(int signal, F_STACK_FRAME *native_stack)
{
	gc_off = true;
	general_error(ERROR_SIGNAL,tag_fixnum(signal),F,false,native_stack);
}

void type_error(CELL type, CELL tagged)
{
	simple_error(ERROR_TYPE,tag_fixnum(type),tagged);
}

void divide_by_zero_error(void)
{
	simple_error(ERROR_DIVIDE_BY_ZERO,F,F);
}

void memory_error(void)
{
	simple_error(ERROR_MEMORY,F,F);
}
