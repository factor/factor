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

// Legacy error functions (kept for compatibility)
[[noreturn]] void fatal_error(const char* msg, cell tagged);
void critical_error(const char* msg, cell tagged);

// Modern error handling with improved diagnostics
enum class ErrorSeverity {
  CRITICAL,  // Bug that should be reported but execution can continue
  FATAL      // Unrecoverable error that requires abort
};

struct ErrorLocation {
  const char* file;
  int line;
  const char* function;
  
  ErrorLocation(const char* f = __builtin_FILE(), 
                int l = __builtin_LINE(),
                const char* fn = __builtin_FUNCTION())
    : file(f), line(l), function(fn) {}
};

struct ErrorContext {
  const char* message;
  cell value;
  ErrorLocation location;
  ErrorSeverity severity;
  
  ErrorContext(const char* msg, cell val = 0, 
               ErrorSeverity sev = ErrorSeverity::FATAL,
               const ErrorLocation& loc = ErrorLocation())
    : message(msg), value(val), location(loc), severity(sev) {}
};

// Modern error handling functions
void report_error(const ErrorContext& ctx);

// Macros for capturing source location
#define FATAL_ERROR(msg, val) fatal_error_impl(msg, val, ErrorLocation(__FILE__, __LINE__, __FUNCTION__))
#define CRITICAL_ERROR(msg, val) critical_error_impl(msg, val, ErrorLocation(__FILE__, __LINE__, __FUNCTION__))

// Implementation functions (use macros above instead)
[[noreturn]] void fatal_error_impl(const char* msg, cell tagged, const ErrorLocation& loc);
void critical_error_impl(const char* msg, cell tagged, const ErrorLocation& loc);
void memory_signal_handler_impl();
void fp_signal_handler_impl();
void synchronous_signal_handler_impl();

}
