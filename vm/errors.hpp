namespace factor {

// Runtime errors must be kept in sync with:
//   basis/debugger/debugger.factor
//   core/kernel/kernel.factor
#define KERNEL_ERROR 0xfac7

enum vm_error_type {
  ERROR_EXPIRED = 0,
  ERROR_IO,
  ERROR_UNUSED,
  ERROR_TYPE,
  ERROR_DIVIDE_BY_ZERO,
  ERROR_SIGNAL,
  ERROR_ARRAY_SIZE,
  ERROR_OUT_OF_FIXNUM_RANGE,
  ERROR_FFI,
  ERROR_UNDEFINED_SYMBOL,
  ERROR_DATASTACK_UNDERFLOW,
  ERROR_DATASTACK_OVERFLOW,
  ERROR_RETAINSTACK_UNDERFLOW,
  ERROR_RETAINSTACK_OVERFLOW,
  ERROR_CALLSTACK_UNDERFLOW,
  ERROR_CALLSTACK_OVERFLOW,
  ERROR_MEMORY,
  ERROR_FP_TRAP,
  ERROR_INTERRUPT,
  ERROR_CALLBACK_SPACE_OVERFLOW
};

[[noreturn]] void fatal_error(const char* msg, cell tagged);
void critical_error(const char* msg, cell tagged);
void memory_signal_handler_impl();
void fp_signal_handler_impl();
void synchronous_signal_handler_impl();

}
