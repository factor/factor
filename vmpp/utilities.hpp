void *safe_malloc(size_t size);
F_CHAR *safe_strdup(const F_CHAR *str);

void nl(void);
void print_string(const char *str);
void print_cell(CELL x);
void print_cell_hex(CELL x);
void print_cell_hex_pad(CELL x);
void print_fixnum(F_FIXNUM x);
CELL read_cell_hex(void);
