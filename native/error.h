#define ERROR_EXPIRED (0<<3)
#define ERROR_IO_TASK_TWICE (1<<3)
#define ERROR_IO_TASK_NONE (2<<3)
#define ERROR_INCOMPATIBLE_PORT (3<<3)
#define ERROR_IO (4<<3)
#define ERROR_UNDEFINED_WORD (5<<3)
#define ERROR_TYPE (6<<3)
#define ERROR_RANGE (7<<3)
#define ERROR_FLOAT_FORMAT (8<<3)
#define ERROR_SIGNAL (9<<3)
#define ERROR_NEGATIVE_ARRAY_SIZE (10<<3)
#define ERROR_BAD_PRIMITIVE (11<<3)
#define ERROR_C_STRING (12<<3)
#define ERROR_FFI_DISABLED (13<<3)
#define ERROR_FFI (14<<3)
#define ERROR_CLOSED (15<<3)

/* When throw_error throws an error, it sets this global and
longjmps back to the top-level. */
CELL thrown_error;
CELL thrown_keep_stacks;
CELL thrown_ds;
CELL thrown_cs;

void init_errors(void);
void fatal_error(char* msg, CELL tagged);
void critical_error(char* msg, CELL tagged);
void throw_error(CELL error, bool keep_stacks);
void early_error(CELL error);
void general_error(CELL error, CELL tagged);
void signal_error(int signal);
void type_error(CELL type, CELL tagged);
void primitive_throw(void);
void range_error(CELL tagged, FIXNUM index, CELL max);
