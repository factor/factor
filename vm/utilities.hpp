namespace factor
{

void *safe_malloc(size_t size);
vm_char *safe_strdup(const vm_char *str);

void nl();
void print_string(const char *str);
void print_cell(cell x);
void print_cell_hex(cell x);
void print_cell_hex_pad(cell x);
void print_fixnum(fixnum x);
cell read_cell_hex();

}
