#include "master.h"

void uncurry(CELL obj)
{
	F_CURRY *curry;

	switch(type_of(obj))
	{
	case QUOTATION_TYPE:
		dpush(obj);
		break;
	case CURRY_TYPE:
		curry = untag_object(obj);
		dpush(curry->obj);
		uncurry(curry->quot);
		break;
	default:
		type_error(QUOTATION_TYPE,obj);
		break;
	}
}

XT default_word_xt(F_WORD *word)
{
	if(word->def == T)
		return dosym;
	else if(type_of(word->def) == QUOTATION_TYPE)
	{
		if(profiling)
			return docol_profiling;
		else
			return docol;
	}
	else if(type_of(word->def) == FIXNUM_TYPE)
		return primitives[to_fixnum(word->def)];
	else
		return undefined;
}

DEFINE_PRIMITIVE(uncurry)
{
	uncurry(dpop());
}

DEFINE_PRIMITIVE(getenv)
{
	F_FIXNUM e = untag_fixnum_fast(dpeek());
	drepl(userenv[e]);
}

DEFINE_PRIMITIVE(setenv)
{
	F_FIXNUM e = untag_fixnum_fast(dpop());
	CELL value = dpop();
	userenv[e] = value;
}

DEFINE_PRIMITIVE(exit)
{
	exit(to_fixnum(dpop()));
}

DEFINE_PRIMITIVE(os_env)
{
	char *name = unbox_char_string();
	char *value = getenv(name);
	if(value == NULL)
		dpush(F);
	else
		box_char_string(value);
}

DEFINE_PRIMITIVE(eq)
{
	CELL lhs = dpop();
	CELL rhs = dpeek();
	drepl((lhs == rhs) ? T : F);
}

DEFINE_PRIMITIVE(millis)
{
	box_unsigned_8(current_millis());
}

DEFINE_PRIMITIVE(sleep)
{
	sleep_millis(to_cell(dpop()));
}

DEFINE_PRIMITIVE(type)
{
	drepl(tag_fixnum(type_of(dpeek())));
}

DEFINE_PRIMITIVE(tag)
{
	drepl(tag_fixnum(TAG(dpeek())));
}

DEFINE_PRIMITIVE(class_hash)
{
	CELL obj = dpeek();
	CELL tag = TAG(obj);
	if(tag == TUPLE_TYPE)
	{
		F_WORD *class = untag_object(get(SLOT(obj,2)));
		drepl(class->hashcode);
	}
	else if(tag == OBJECT_TYPE)
		drepl(get(UNTAG(obj)));
	else
		drepl(tag_fixnum(tag));
}

DEFINE_PRIMITIVE(slot)
{
	F_FIXNUM slot = untag_fixnum_fast(dpop());
	CELL obj = dpop();
	dpush(get(SLOT(obj,slot)));
}

DEFINE_PRIMITIVE(set_slot)
{
	F_FIXNUM slot = untag_fixnum_fast(dpop());
	CELL obj = dpop();
	CELL value = dpop();
	set_slot(obj,slot,value);
}

void fatal_error(char* msg, CELL tagged)
{
	fprintf(stderr,"fatal_error: %s %lx\n",msg,tagged);
	exit(1);
}

void critical_error(char* msg, CELL tagged)
{
	fprintf(stderr,"You have triggered a bug in Factor. Please report.\n");
	fprintf(stderr,"critical_error: %s %lx\n",msg,tagged);
	factorbug();
}

void throw_error(CELL error, F_STACK_FRAME *callstack_top)
{
	/* If error was thrown during heap scan, we re-enable the GC */
	gc_off = false;

	/* Reset local roots */
	extra_roots = stack_chain->extra_roots;

	/* If we had an underflow or overflow, stack pointers might be
	out of bounds */
	fix_stacks();

	dpush(error);

	/* If the error handler is set, we rewind any C stack frames and
	pass the error to user-space. */
	if(userenv[BREAK_ENV] != F)
	{
		/* Errors thrown from C code pass NULL for this parameter.
		Errors thrown from Factor code, or signal handlers, pass the
		actual stack pointer at the time, since the saved pointer is
		not necessarily up to date at that point. */
		if(!callstack_top)
			callstack_top = stack_chain->callstack_top;

		throw_impl(userenv[BREAK_ENV],callstack_top);
	}
	/* Error was thrown in early startup before error handler is set, just
	crash. */
	else
	{
		fprintf(stderr,"You have triggered a bug in Factor. Please report.\n");
		fprintf(stderr,"early_error: ");
		print_obj(error);
		fprintf(stderr,"\n");
		factorbug();
	}
}

void general_error(F_ERRORTYPE error, CELL arg1, CELL arg2,
	F_STACK_FRAME *callstack_top)
{
	throw_error(allot_array_4(userenv[ERROR_ENV],
		tag_fixnum(error),arg1,arg2),callstack_top);
}

void type_error(CELL type, CELL tagged)
{
	general_error(ERROR_TYPE,tag_fixnum(type),tagged,NULL);
}

void not_implemented_error(void)
{
	general_error(ERROR_NOT_IMPLEMENTED,F,F,NULL);
}

/* This function is called from the undefined function in cpu_*.S */
F_FASTCALL void undefined_error(CELL word, F_STACK_FRAME *callstack_top)
{
	stack_chain->callstack_top = callstack_top;
	general_error(ERROR_UNDEFINED_WORD,word,F,NULL);
}

/* Test if 'fault' is in the guard page at the top or bottom (depending on
offset being 0 or -1) of area+area_size */
bool in_page(CELL fault, CELL area, CELL area_size, int offset)
{
	int pagesize = getpagesize();
	area += area_size;
	area += offset * pagesize;

	return fault >= area && fault <= area + pagesize;
}

void memory_protection_error(CELL addr, F_STACK_FRAME *native_stack)
{
	if(in_page(addr, ds_bot, 0, -1))
		general_error(ERROR_DS_UNDERFLOW,F,F,native_stack);
	else if(in_page(addr, ds_bot, ds_size, 0))
		general_error(ERROR_DS_OVERFLOW,F,F,native_stack);
	else if(in_page(addr, rs_bot, 0, -1))
		general_error(ERROR_RS_UNDERFLOW,F,F,native_stack);
	else if(in_page(addr, rs_bot, rs_size, 0))
		general_error(ERROR_RS_OVERFLOW,F,F,native_stack);
	else if(in_page(addr, nursery->end, 0, 0))
		critical_error("allot_object() missed GC check",0);
	else if(in_page(addr, extra_roots_region->start, 0, -1))
		critical_error("local root underflow",0);
	else if(in_page(addr, extra_roots_region->end, 0, 0))
		critical_error("local root overflow",0);
	else
		general_error(ERROR_MEMORY,allot_cell(addr),F,native_stack);
}

void signal_error(int signal, F_STACK_FRAME *native_stack)
{
	general_error(ERROR_SIGNAL,tag_fixnum(signal),F,native_stack);
}

void divide_by_zero_error(F_STACK_FRAME *native_stack)
{
	general_error(ERROR_DIVIDE_BY_ZERO,F,F,native_stack);
}

void memory_signal_handler_impl(void)
{
    memory_protection_error(signal_fault_addr,signal_callstack_top);
}

void divide_by_zero_signal_handler_impl(void)
{
    divide_by_zero_error(signal_callstack_top);
}

void misc_signal_handler_impl(void)
{
    signal_error(signal_number,signal_callstack_top);
}

DEFINE_PRIMITIVE(throw)
{
	uncurry(dpop());
	throw_impl(dpop(),stack_chain->callstack_top);
}

void enable_word_profiling(F_WORD *word)
{
	if(word->xt == docol)
		word->xt = docol_profiling;
}

void disable_word_profiling(F_WORD *word)
{
	if(word->xt == docol_profiling)
		word->xt = docol;
}

DEFINE_PRIMITIVE(profiling)
{
	profiling = to_boolean(dpop());

	begin_scan();

	CELL obj;
	while((obj = next_object()) != F)
	{
		if(type_of(obj) == WORD_TYPE)
		{
			if(profiling)
				enable_word_profiling(untag_object(obj));
			else
				disable_word_profiling(untag_object(obj));
		}
	}

	gc_off = false; /* end heap scan */
}
