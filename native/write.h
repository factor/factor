void write_step(PORT* port);
bool can_write(PORT* port, FIXNUM len);
void primitive_can_write(void);
void primitive_add_write_io_task(void);
bool perform_write_io_task(PORT* port);
void write_char_8(PORT* port, FIXNUM ch);
void write_string_8(PORT* port, STRING* str);
void primitive_write_8(void);
