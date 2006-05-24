typedef enum
{
	ERROR_EXPIRED
	ERROR_IO
	ERROR_UNDEFINED_WORD
	ERROR_TYPE
	ERROR_SIGNAL
	ERROR_NEGATIVE_ARRAY_SIZE
	ERROR_C_STRING
	ERROR_FFI
	ERROR_HEAP_SCAN
	ERROR_UNDEFINED_SYMBOL
	ERROR_USER_INTERRUPT
	ERROR_DS_UNDERFLOW
	ERROR_DS_OVERFLOW
	ERROR_RS_UNDERFLOW
	ERROR_RS_OVERFLOW
	ERROR_CS_UNDERFLOW
	ERROR_CS_OVERFLOW
	ERROR_OBJECTIVE_C
} F_ERRORTYPE;

/* Are we throwing an error? */
bool throwing;
/* When throw_error throws an error, it sets this global and
longjmps back to the top-level. */
CELL thrown_error;
CELL thrown_keep_stacks;
/* Since longjmp restores registers, we must save all these values. */
CELL thrown_ds;
CELL thrown_rs;

void fatal_error(char* msg, CELL tagged);
void critical_error(char* msg, CELL tagged);
void throw_error(CELL error, bool keep_stacks);
void early_error(CELL error);
void general_error(F_ERRORTYPE error, CELL arg1, CELL arg2, bool keep_stacks);
void signal_error(int signal);
void type_error(CELL type, CELL tagged);
void primitive_throw(void);
void primitive_die(void);
