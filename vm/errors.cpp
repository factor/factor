#include "master.hpp"

namespace factor {

bool factor_vm::fatal_erroring_p;

static inline void fa_diddly_atal_error() {
  printf("fatal_error in fatal_error!\n");
  breakpoint();
  ::_exit(86);
}

void fatal_error(const char* msg, cell tagged) {
  if (factor_vm::fatal_erroring_p)
    fa_diddly_atal_error();

  factor_vm::fatal_erroring_p = true;

  std::cout << "fatal_error: " << msg;
  std::cout << ": " << (void*)tagged;
  std::cout << std::endl << std::endl;
  factor_vm* vm = current_vm();
  if (vm->data) {
    vm->dump_memory_layout(std::cout);
  }
  abort();
}

void critical_error(const char* msg, cell tagged) {
  std::cout << "You have triggered a bug in Factor. Please report.\n";
  std::cout << "critical_error: " << msg;
  std::cout << ": " << std::hex << tagged << std::dec;
  std::cout << std::endl;
  current_vm()->factorbug();
}

// Allocates memory
void factor_vm::general_error(vm_error_type error, cell arg1_, cell arg2_) {

  data_root<object> arg1(arg1_, this);
  data_root<object> arg2(arg2_, this);

  faulting_p = true;

  // If we had an underflow or overflow, data or retain stack
  // pointers might be out of bounds, so fix them before allocating
  // anything
  ctx->fix_stacks();

  // If error was thrown during heap scan, we re-enable the GC
  gc_off = false;

  // If the error handler is set, we rewind any C stack frames and
  // pass the error to user-space.
  if (!current_gc && to_boolean(special_objects[ERROR_HANDLER_QUOT])) {
#ifdef FACTOR_DEBUG
    // Doing a GC here triggers all kinds of funny errors
    primitive_compact_gc();
#endif

    // Now its safe to allocate and GC
    cell error_object =
        allot_array_4(tag_fixnum(KERNEL_ERROR), tag_fixnum(error),
                      arg1.value(), arg2.value());
    ctx->push(error_object);

    // Clear the data roots since arg1 and arg2's destructors won't be
    // called.
    data_roots.clear();

    // The unwind-native-frames subprimitive will clear faulting_p
    // if it was successfully reached.
    unwind_native_frames(special_objects[ERROR_HANDLER_QUOT],
                         ctx->callstack_top);
  } // Error was thrown in early startup before error handler is set, so just
    // crash.
  else {
    std::cout << "You have triggered a bug in Factor. Please report.\n";
    std::cout << "error: " << error << std::endl;
    std::cout << "arg 1: ";
    print_obj(std::cout, arg1.value());
    std::cout << std::endl;
    std::cout << "arg 2: ";
    print_obj(std::cout, arg2.value());
    std::cout << std::endl;
    factorbug();
    abort();
  }
}

// Allocates memory
void factor_vm::type_error(cell type, cell tagged) {
  general_error(ERROR_TYPE, tag_fixnum(type), tagged);
}

void factor_vm::set_memory_protection_error(cell fault_addr, cell fault_pc) {
  // Called from the OS-specific top halves of the signal handlers to
  // make sure it's safe to dispatch to memory_signal_handler_impl.
  if (fatal_erroring_p)
    fa_diddly_atal_error();
  if (faulting_p && !code->safepoint_p(fault_addr))
    fatal_error("Double fault", fault_addr);
  else if (fep_p)
    fatal_error("Memory protection fault during low-level debugger", fault_addr);
  else if (atomic::load(&current_gc_p))
    fatal_error("Memory protection fault during gc", fault_addr);
  signal_fault_addr = fault_addr;
  signal_fault_pc = fault_pc;
}

// Allocates memory
void factor_vm::divide_by_zero_error() {
  general_error(ERROR_DIVIDE_BY_ZERO, false_object, false_object);
}

// Allocates memory
void memory_signal_handler_impl() {
  factor_vm* vm = current_vm();
  if (vm->code->safepoint_p(vm->signal_fault_addr)) {
    vm->handle_safepoint(vm->signal_fault_pc);
  }
  else {
    vm_error_type type = vm->ctx->address_to_error(vm->signal_fault_addr);
    cell number = vm->from_unsigned_cell(vm->signal_fault_addr);
    vm->general_error(type, number, false_object);
  }
  if (!vm->signal_resumable) {
    // In theory we should only get here if the callstack overflowed during a
    // safepoint
    vm->general_error(ERROR_CALLSTACK_OVERFLOW, false_object, false_object);
  }
}

// Allocates memory
void synchronous_signal_handler_impl() {
  factor_vm* vm = current_vm();
  vm->general_error(ERROR_SIGNAL,
                    vm->from_unsigned_cell(vm->signal_number),
                    false_object);
}

// Allocates memory
void fp_signal_handler_impl() {
  factor_vm* vm = current_vm();

  // Clear pending exceptions to avoid getting stuck in a loop
  vm->set_fpu_state(vm->get_fpu_state());

  vm->general_error(ERROR_FP_TRAP,
                    tag_fixnum(vm->signal_fpu_status),
                    false_object);
}
}
