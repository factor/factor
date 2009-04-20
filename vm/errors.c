#include "master.h"

void out_of_memory(void)
{
	print_string("Out of memory\n\n");
	dump_generations();
	exit(1);
}

void fatal_error(char* msg, CELL tagged)
{
	print_string("fatal_error: "); print_string(msg);
	print_string(": "); print_cell_hex(tagged); nl();
	exit(1);
}

void critical_error(char* msg, CELL tagged)
{
	print_string("You have triggered a bug in Factor. Please report.\n");
	print_string("critical_error: "); print_string(msg);
	print_string(": "); print_cell_hex(tagged); nl();
	factorbug();
}

void throw_error(CELL error, F_STACK_FRAME *callstack_top)
{
	/* If the error handler is set, we rewind any C stack frames and
	pass the error to user-space. */
	if(userenv[BREAK_ENV] != F)
	{
		/* If error was thrown during heap scan, we re-enable the GC */
		gc_off = false;

		/* Reset local roots */
		gc_locals = gc_locals_region->start - CELLS;
		extra_roots = extra_roots_region->start - CELLS;

		/* If we had an underflow or overflow, stack pointers might be
		out of bounds */
		fix_stacks();

		dpush(error);

		/* Errors thrown from C code pass NULL for this parameter.
		Errors thrown from Factor code, or signal handlers, pass the
		actual stack pointer at the time, since the saved pointer is
		not necessarily up to date at that point. */
		if(callstack_top)
		{
			callstack_top = fix_callstack_top(callstack_top,
				stack_chain->callstack_bottom);
		}
		else
			callstack_top = stack_chain->callstack_top;

		throw_impl(userenv[BREAK_ENV],callstack_top);
	}
	/* Error was thrown in early startup before error handler is set, just
	crash. */
	else
	{
		print_string("You have triggered a bug in Factor. Please report.\n");
		print_string("early_error: ");
		print_obj(error);
		nl();
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
	else if(in_page(addr, nursery.end, 0, 0))
		critical_error("allot_object() missed GC check",0);
	else if(in_page(addr, gc_locals_region->start, 0, -1))
		critical_error("gc locals underflow",0);
	else if(in_page(addr, gc_locals_region->end, 0, 0))
		critical_error("gc locals overflow",0);
	else if(in_page(addr, extra_roots_region->start, 0, -1))
		critical_error("extra roots underflow",0);
	else if(in_page(addr, extra_roots_region->end, 0, 0))
		critical_error("extra roots overflow",0);
	else
		general_error(ERROR_MEMORY,allot_cell(addr),F,native_stack);
}

void signal_error(int signal, F_STACK_FRAME *native_stack)
{
	general_error(ERROR_SIGNAL,tag_fixnum(signal),F,native_stack);
}

void divide_by_zero_error(void)
{
	general_error(ERROR_DIVIDE_BY_ZERO,F,F,NULL);
}

void memory_signal_handler_impl(void)
{
	memory_protection_error(signal_fault_addr,signal_callstack_top);
}

void misc_signal_handler_impl(void)
{
	signal_error(signal_number,signal_callstack_top);
}

void primitive_call_clear(void)
{
	throw_impl(dpop(),stack_chain->callstack_bottom);
}

/* For testing purposes */
void primitive_unimplemented(void)
{
	not_implemented_error();
}
