#define ERROR_PORT_EXPIRED (0<<3)
#define ERROR_UNDEFINED_WORD (1<<3)
#define ERROR_TYPE (2<<3)
#define ERROR_RANGE (3<<3)
#define ERROR_UNDERFLOW (4<<3)
#define ERROR_IO (5<<3)
#define ERROR_OVERFLOW (6<<3)
#define ERROR_INCOMPARABLE (7<<3)
#define ERROR_FLOAT_FORMAT (8<<3)
#define ERROR_SIGNAL (9<<3)

void fatal_error(char* msg, CELL tagged);
void critical_error(char* msg, CELL tagged);
void fix_stacks(void);
void throw_error(CELL object);
void general_error(CELL error, CELL tagged);
void type_error(CELL type, CELL tagged);
void range_error(CELL tagged, CELL index, CELL max);
void io_error(const char* func);
