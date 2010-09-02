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
	current_vm()->factorbug();
}

void out_of_memory()
{
	std::cout << "Out of memory\n\n";
	current_vm()->dump_generations();
	exit(1);
}

void factor_vm::throw_error(cell error, stack_frame *stack)
{
	assert(stack);

	/* If the error handler is set, we rewind any C stack frames and
	pass the error to user-space. */
	if(!current_gc && to_boolean(special_objects[ERROR_HANDLER_QUOT]))
	{
		/* If error was thrown during heap scan, we re-enable the GC */
		gc_off = false;

		/* Reset local roots */
		data_roots.clear();
		bignum_roots.clear();
		code_roots.clear();

		/* If we had an underflow or overflow, data or retain stack
		pointers might be out of bounds */
		ctx->fix_stacks();

		ctx->push(error);

		unwind_native_frames(special_objects[ERROR_HANDLER_QUOT],stack);
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

void factor_vm::general_error(vm_error_type error, cell arg1, cell arg2, stack_frame *stack)
{
	throw_error(allot_array_4(special_objects[OBJ_ERROR],
		tag_fixnum(error),arg1,arg2),stack);
}

void factor_vm::general_error(vm_error_type error, cell arg1, cell arg2)
{
	throw_error(allot_array_4(special_objects[OBJ_ERROR],
		tag_fixnum(error),arg1,arg2),ctx->callstack_top);
}

void factor_vm::type_error(cell type, cell tagged)
{
	general_error(ERROR_TYPE,tag_fixnum(type),tagged);
}

void factor_vm::not_implemented_error()
{
	general_error(ERROR_NOT_IMPLEMENTED,false_object,false_object);
}

void factor_vm::memory_protection_error(cell addr, stack_frame *stack)
{
	/* Retain and call stack underflows are not supposed to happen */

	if(ctx->datastack_seg->underflow_p(addr))
		general_error(ERROR_DATASTACK_UNDERFLOW,false_object,false_object,stack);
	else if(ctx->datastack_seg->overflow_p(addr))
		general_error(ERROR_DATASTACK_OVERFLOW,false_object,false_object,stack);
	else if(ctx->retainstack_seg->underflow_p(addr))
		general_error(ERROR_RETAINSTACK_UNDERFLOW,false_object,false_object,stack);
	else if(ctx->retainstack_seg->overflow_p(addr))
		general_error(ERROR_RETAINSTACK_OVERFLOW,false_object,false_object,stack);
	else if(ctx->callstack_seg->underflow_p(addr))
		general_error(ERROR_CALLSTACK_OVERFLOW,false_object,false_object,stack);
	else if(ctx->callstack_seg->overflow_p(addr))
		general_error(ERROR_CALLSTACK_UNDERFLOW,false_object,false_object,stack);
	else
		general_error(ERROR_MEMORY,from_unsigned_cell(addr),false_object,stack);
}

void factor_vm::signal_error(cell signal, stack_frame *stack)
{
	general_error(ERROR_SIGNAL,from_unsigned_cell(signal),false_object,stack);
}

void factor_vm::divide_by_zero_error()
{
	general_error(ERROR_DIVIDE_BY_ZERO,false_object,false_object);
}

void factor_vm::fp_trap_error(unsigned int fpu_status, stack_frame *stack)
{
	general_error(ERROR_FP_TRAP,tag_fixnum(fpu_status),false_object,stack);
}

/* For testing purposes */
void factor_vm::primitive_unimplemented()
{
	not_implemented_error();
}

void factor_vm::memory_signal_handler_impl()
{
	scrub_return_address(signal_callstack_top);
	memory_protection_error(signal_fault_addr,signal_callstack_top);
}

void memory_signal_handler_impl()
{
	current_vm()->memory_signal_handler_impl();
}

void factor_vm::misc_signal_handler_impl()
{
	scrub_return_address(signal_callstack_top);
	signal_error(signal_number,signal_callstack_top);
}

void misc_signal_handler_impl()
{
	current_vm()->misc_signal_handler_impl();
}

void factor_vm::fp_signal_handler_impl()
{
	/* Clear pending exceptions to avoid getting stuck in a loop */
	set_fpu_state(get_fpu_state());

	scrub_return_address(signal_callstack_top);
	fp_trap_error(signal_fpu_status,signal_callstack_top);
}

void fp_signal_handler_impl()
{
	current_vm()->fp_signal_handler_impl();
}

}
