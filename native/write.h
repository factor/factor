void write_step(F_PORT* port);
bool can_write(F_PORT* port, F_FIXNUM len);
void primitive_can_write(void);
void primitive_add_write_io_task(void);
bool perform_write_io_task(F_PORT* port);
void write_char_8(F_PORT* port, F_FIXNUM ch);
void write_string_raw(F_PORT* port, BYTE* str, CELL len);
void write_string_8(F_PORT* port, F_STRING* str);
void primitive_write_8(void);
