#include "master.hpp"

namespace factor
{

bool factor_vm::fatal_erroring_p;

static inline void fa_diddly_atal_error()
{
	printf("fatal_error in fatal_error!\n");
	breakpoint();
	::_exit(86);
}

void fatal_error(const char *msg, cell tagged)
{
	if (factor_vm::fatal_erroring_p)
		fa_diddly_atal_error();

	factor_vm::fatal_erroring_p = true;

	std::cout << "fatal_error: " << msg;
	std::cout << ": " << (void*)tagged;
	std::cout << std::endl;
	abort();
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
	abort();
}

/* Allocates memory */
void factor_vm::general_error(vm_error_type error, cell arg1_, cell arg2_)
{
	data_root<object> arg1(arg1_,this);
	data_root<object> arg2(arg2_,this);

	faulting_p = true;

	/* If we had an underflow or overflow, data or retain stack
	pointers might be out of bounds, so fix them before allocating
	anything */
	ctx->fix_stacks();

	/* If error was thrown during heap scan, we re-enable the GC */
	gc_off = false;

	/* If the error handler is set, we rewind any C stack frames and
	pass the error to user-space. */
	if(!current_gc && to_boolean(special_objects[ERROR_HANDLER_QUOT]))
	{
#ifdef FACTOR_DEBUG
		/* Doing a GC here triggers all kinds of funny errors */
		primitive_compact_gc();
#endif

		/* Now its safe to allocate and GC */
		cell error_object = allot_array_4(special_objects[OBJ_ERROR],
			tag_fixnum(error),arg1.value(),arg2.value());

		ctx->push(error_object);

		/* Reset local roots */
		data_roots.clear();
		bignum_roots.clear();
		code_roots.clear();

		/* The unwind-native-frames subprimitive will clear faulting_p
		if it was successfully reached. */
		unwind_native_frames(special_objects[ERROR_HANDLER_QUOT],
			ctx->callstack_top);
	}
	/* Error was thrown in early startup before error handler is set, so just
	crash. */
	else
	{
		std::cout << "You have triggered a bug in Factor. Please report.\n";
		std::cout << "error: " << error << std::endl;
		std::cout << "arg 1: "; print_obj(arg1.value()); std::cout << std::endl;
		std::cout << "arg 2: "; print_obj(arg2.value()); std::cout << std::endl;
		factorbug();
		abort();
	}
}

void factor_vm::type_error(cell type, cell tagged)
{
	general_error(ERROR_TYPE,tag_fixnum(type),tagged);
}

void factor_vm::not_implemented_error()
{
	general_error(ERROR_NOT_IMPLEMENTED,false_object,false_object);
}

void factor_vm::verify_memory_protection_error(cell addr)
{
	/* Called from the OS-specific top halves of the signal handlers to
	make sure it's safe to dispatch to memory_protection_error */
	if(fatal_erroring_p)
		fa_diddly_atal_error();
	if(faulting_p && !code->safepoint_p(addr))
		fatal_error("Double fault", addr);
	else if(fep_p)
		fatal_error("Memory protection fault during low-level debugger", addr);
	else if(atomic::load(&current_gc_p))
		fatal_error("Memory protection fault during gc", addr);
}

/* Allocates memory */
void factor_vm::memory_protection_error(cell pc, cell addr)
{
	if(code->safepoint_p(addr))
		safepoint.handle_safepoint(this, pc);
	else if(ctx->datastack_seg->underflow_p(addr))
		general_error(ERROR_DATASTACK_UNDERFLOW,false_object,false_object);
	else if(ctx->datastack_seg->overflow_p(addr))
		general_error(ERROR_DATASTACK_OVERFLOW,false_object,false_object);
	else if(ctx->retainstack_seg->underflow_p(addr))
		general_error(ERROR_RETAINSTACK_UNDERFLOW,false_object,false_object);
	else if(ctx->retainstack_seg->overflow_p(addr))
		general_error(ERROR_RETAINSTACK_OVERFLOW,false_object,false_object);
	else if(ctx->callstack_seg->underflow_p(addr))
		general_error(ERROR_CALLSTACK_OVERFLOW,false_object,false_object);
	else if(ctx->callstack_seg->overflow_p(addr))
		general_error(ERROR_CALLSTACK_UNDERFLOW,false_object,false_object);
	else
		general_error(ERROR_MEMORY,from_unsigned_cell(addr),false_object);
}

/* Allocates memory */
void factor_vm::signal_error(cell signal)
{
	general_error(ERROR_SIGNAL,from_unsigned_cell(signal),false_object);
}

void factor_vm::divide_by_zero_error()
{
	general_error(ERROR_DIVIDE_BY_ZERO,false_object,false_object);
}

void factor_vm::fp_trap_error(unsigned int fpu_status)
{
	general_error(ERROR_FP_TRAP,tag_fixnum(fpu_status),false_object);
}

/* For testing purposes */
void factor_vm::primitive_unimplemented()
{
	not_implemented_error();
}

void factor_vm::memory_signal_handler_impl()
{
	memory_protection_error(signal_fault_pc, signal_fault_addr);
	if (!signal_resumable)
	{
		/* In theory we should only get here if the callstack overflowed during a
		safepoint */
		general_error(ERROR_CALLSTACK_OVERFLOW,false_object,false_object);
	}
}

void memory_signal_handler_impl()
{
	current_vm()->memory_signal_handler_impl();
}

void factor_vm::synchronous_signal_handler_impl()
{
	signal_error(signal_number);
}

void synchronous_signal_handler_impl()
{
	current_vm()->synchronous_signal_handler_impl();
}

void factor_vm::fp_signal_handler_impl()
{
	/* Clear pending exceptions to avoid getting stuck in a loop */
	set_fpu_state(get_fpu_state());

	fp_trap_error(signal_fpu_status);
}

void fp_signal_handler_impl()
{
	current_vm()->fp_signal_handler_impl();
}
}
