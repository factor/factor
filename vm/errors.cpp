#include "master.hpp"

namespace factor
{

/* Global variables used to pass fault handler state from signal handler to
user-space */
cell signal_number;
cell signal_fault_addr;
stack_frame *signal_callstack_top;

void out_of_memory()
{
	print_string("Out of memory\n\n");
	dump_generations();
	exit(1);
}

void fatal_error(const char* msg, cell tagged)
{
	print_string("fatal_error: "); print_string(msg);
	print_string(": "); print_cell_hex(tagged); nl();
	exit(1);
}

void critical_error(const char* msg, cell tagged)
{
	print_string("You have triggered a bug in Factor. Please report.\n");
	print_string("critical_error: "); print_string(msg);
	print_string(": "); print_cell_hex(tagged); nl();
	factorbug();
}

void throw_error(cell error, stack_frame *callstack_top)
{
	/* If the error handler is set, we rewind any C stack frames and
	pass the error to user-space. */
	if(userenv[BREAK_ENV] != F)
	{
		/* If error was thrown during heap scan, we re-enable the GC */
		gc_off = false;

		/* Reset local roots */
		gc_locals = gc_locals_region->start - sizeof(cell);
		gc_bignums = gc_bignums_region->start - sizeof(cell);

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

void general_error(vm_error_type error, cell arg1, cell arg2,
	stack_frame *callstack_top)
{
	throw_error(allot_array_4(userenv[ERROR_ENV],
		tag_fixnum(error),arg1,arg2),callstack_top);
}

void type_error(cell type, cell tagged)
{
	general_error(ERROR_TYPE,tag_fixnum(type),tagged,NULL);
}

void not_implemented_error()
{
	general_error(ERROR_NOT_IMPLEMENTED,F,F,NULL);
}

/* Test if 'fault' is in the guard page at the top or bottom (depending on
offset being 0 or -1) of area+area_size */
bool in_page(cell fault, cell area, cell area_size, int offset)
{
	int pagesize = getpagesize();
	area += area_size;
	area += offset * pagesize;

	return fault >= area && fault <= area + pagesize;
}

void memory_protection_error(cell addr, stack_frame *native_stack)
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
	else
		general_error(ERROR_MEMORY,allot_cell(addr),F,native_stack);
}

void signal_error(int signal, stack_frame *native_stack)
{
	general_error(ERROR_SIGNAL,tag_fixnum(signal),F,native_stack);
}

void divide_by_zero_error()
{
	general_error(ERROR_DIVIDE_BY_ZERO,F,F,NULL);
}

PRIMITIVE(call_clear)
{
	throw_impl(dpop(),stack_chain->callstack_bottom);
}

/* For testing purposes */
PRIMITIVE(unimplemented)
{
	not_implemented_error();
}

void memory_signal_handler_impl()
{
	memory_protection_error(signal_fault_addr,signal_callstack_top);
}

void misc_signal_handler_impl()
{
	signal_error(signal_number,signal_callstack_top);
}

}
