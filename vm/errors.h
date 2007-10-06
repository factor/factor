/* Runtime errors */
typedef enum
{
	ERROR_EXPIRED = 0,
	ERROR_IO,
	ERROR_UNDEFINED_WORD,
	ERROR_TYPE,
	ERROR_DIVIDE_BY_ZERO,
	ERROR_SIGNAL,
	ERROR_ARRAY_SIZE,
	ERROR_C_STRING,
	ERROR_FFI,
	ERROR_HEAP_SCAN,
	ERROR_UNDEFINED_SYMBOL,
	ERROR_DS_UNDERFLOW,
	ERROR_DS_OVERFLOW,
	ERROR_RS_UNDERFLOW,
	ERROR_RS_OVERFLOW,
	ERROR_MEMORY,
	ERROR_NOT_IMPLEMENTED,
} F_ERRORTYPE;

void fatal_error(char* msg, CELL tagged);
void critical_error(char* msg, CELL tagged);
DECLARE_PRIMITIVE(die);

void throw_error(CELL error, F_STACK_FRAME *native_stack);
void general_error(F_ERRORTYPE error, CELL arg1, CELL arg2, F_STACK_FRAME *native_stack);
void divide_by_zero_error(F_STACK_FRAME *native_stack);
void memory_protection_error(CELL addr, F_STACK_FRAME *native_stack);
void signal_error(int signal, F_STACK_FRAME *native_stack);
void type_error(CELL type, CELL tagged);
void not_implemented_error(void);

F_FASTCALL void undefined_error(CELL word, F_STACK_FRAME *callstack_top);

DECLARE_PRIMITIVE(throw);
DECLARE_PRIMITIVE(call_clear);

INLINE void type_check(CELL type, CELL tagged)
{
	if(type_of(tagged) != type) type_error(type,tagged);
}
