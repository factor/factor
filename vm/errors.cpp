#include "master.hpp"

namespace factor
{

void fatal_error(const char *msg, cell tagged)
{
	std::cout << "fatal_error: " << msg;
	std::cout << ": " << std::hex << tagged << std::dec;
	std::cout << std::endl;
	exit(1);
}

void critical_error(const char *msg, cell tagged)
{
	std::cout << "You have triggered a bug in Factor. Please report.\n";
	std::cout << "critical_error: " << msg;
	std::cout << ": " << std::hex << tagged << std::dec;
	std::cout << std::endl;
	tls_vm()->factorbug();
}

void out_of_memory()
{
	std::cout << "Out of memory\n\n";
	tls_vm()->dump_generations();
	exit(1);
}

void factor_vm::throw_error(cell error, stack_frame *callstack_top)
{
	/* If the error handler is set, we rewind any C stack frames and
	pass the error to user-space. */
	if(!current_gc && to_boolean(userenv[BREAK_ENV]))
	{
		/* If error was thrown during heap scan, we re-enable the GC */
		gc_off = false;

		/* Reset local roots */
		gc_locals.clear();
		gc_bignums.clear();

		/* If we had an underflow or overflow, stack pointers might be
		out of bounds */
		fix_stacks();

		dpush(error);

		/* Errors thrown from C code pass NULL for this parameter.
		Errors thrown from Factor code, or signal handlers, pass the
		actual stack pointer at the time, since the saved pointer is
		not necessarily up to date at that point. */
		if(callstack_top)
			callstack_top = fix_callstack_top(callstack_top,ctx->callstack_bottom);
		else
			callstack_top = ctx->callstack_top;

		throw_impl(userenv[BREAK_ENV],callstack_top,this);
	}
	/* Error was thrown in early startup before error handler is set, just
	crash. */
	else
	{
		std::cout << "You have triggered a bug in Factor. Please report.\n";
		std::cout << "early_error: ";
		print_obj(error);
		std::cout << std::endl;
		factorbug();
	}
}

void factor_vm::general_error(vm_error_type error, cell arg1, cell arg2, stack_frame *callstack_top)
{
	throw_error(allot_array_4(userenv[ERROR_ENV],
		tag_fixnum(error),arg1,arg2),callstack_top);
}

void factor_vm::type_error(cell type, cell tagged)
{
	general_error(ERROR_TYPE,tag_fixnum(type),tagged,NULL);
}

void factor_vm::not_implemented_error()
{
	general_error(ERROR_NOT_IMPLEMENTED,false_object,false_object,NULL);
}

/* Test if 'fault' is in the guard page at the top or bottom (depending on
offset being 0 or -1) of area+area_size */
bool factor_vm::in_page(cell fault, cell area, cell area_size, int offset)
{
	int pagesize = getpagesize();
	area += area_size;
	area += offset * pagesize;

	return fault >= area && fault <= area + pagesize;
}

void factor_vm::memory_protection_error(cell addr, stack_frame *native_stack)
{
	if(in_page(addr, ds_bot, 0, -1))
		general_error(ERROR_DS_UNDERFLOW,false_object,false_object,native_stack);
	else if(in_page(addr, ds_bot, ds_size, 0))
		general_error(ERROR_DS_OVERFLOW,false_object,false_object,native_stack);
	else if(in_page(addr, rs_bot, 0, -1))
		general_error(ERROR_RS_UNDERFLOW,false_object,false_object,native_stack);
	else if(in_page(addr, rs_bot, rs_size, 0))
		general_error(ERROR_RS_OVERFLOW,false_object,false_object,native_stack);
	else if(in_page(addr, nursery.end, 0, 0))
		critical_error("allot_object() missed GC check",0);
	else
		general_error(ERROR_MEMORY,allot_cell(addr),false_object,native_stack);
}

void factor_vm::signal_error(int signal, stack_frame *native_stack)
{
	general_error(ERROR_SIGNAL,allot_cell(signal),false_object,native_stack);
}

void factor_vm::divide_by_zero_error()
{
	general_error(ERROR_DIVIDE_BY_ZERO,false_object,false_object,NULL);
}

void factor_vm::fp_trap_error(unsigned int fpu_status, stack_frame *signal_callstack_top)
{
	general_error(ERROR_FP_TRAP,tag_fixnum(fpu_status),false_object,signal_callstack_top);
}

void factor_vm::primitive_call_clear()
{
	throw_impl(dpop(),ctx->callstack_bottom,this);
}

/* For testing purposes */
void factor_vm::primitive_unimplemented()
{
	not_implemented_error();
}

void factor_vm::memory_signal_handler_impl()
{
	memory_protection_error(signal_fault_addr,signal_callstack_top);
}

void memory_signal_handler_impl()
{
	tls_vm()->memory_signal_handler_impl();
}

void factor_vm::misc_signal_handler_impl()
{
	signal_error(signal_number,signal_callstack_top);
}

void misc_signal_handler_impl()
{
	tls_vm()->misc_signal_handler_impl();
}

void factor_vm::fp_signal_handler_impl()
{
	fp_trap_error(signal_fpu_status,signal_callstack_top);
}

void fp_signal_handler_impl()
{
	tls_vm()->fp_signal_handler_impl();
}

}
