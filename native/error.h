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
#define ERROR_DATASTACK_UNDERFLOW (15<<3)
#define ERROR_DATASTACK_OVERFLOW (16<<3)
#define ERROR_CALLSTACK_UNDERFLOW (17<<3)
#define ERROR_CALLSTACK_OVERFLOW (18<<3)
#define ERROR_CLOSED (19<<3)

/* When throw_error throws an error, it sets this global and
longjmps back to the top-level. */
CELL thrown_error;

void init_errors(void);
void fatal_error(char* msg, CELL tagged);
void critical_error(char* msg, CELL tagged);
void throw_error(CELL object);
void general_error(CELL error, CELL tagged);
void type_error(CELL type, CELL tagged);
void primitive_throw(void);
void range_error(CELL tagged, FIXNUM index, CELL max);
