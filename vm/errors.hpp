namespace factor
{

/* Runtime errors */
enum vm_error_type
{
	ERROR_EXPIRED = 0,
	ERROR_IO,
	ERROR_NOT_IMPLEMENTED,
	ERROR_TYPE,
	ERROR_DIVIDE_BY_ZERO,
	ERROR_SIGNAL,
	ERROR_ARRAY_SIZE,
	ERROR_C_STRING,
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
};

void fatal_error(const char *msg, cell tagged);
void critical_error(const char *msg, cell tagged);
void out_of_memory();
void memory_signal_handler_impl();
void fp_signal_handler_impl();
void misc_signal_handler_impl();

}
