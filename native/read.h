bool read_step(F_PORT* port);

#define LINE_SIZE 80

bool read_line_step(F_PORT* port);
bool can_read_line(F_PORT* port);
void primitive_can_read_line(void);
void primitive_add_read_line_io_task(void);
bool perform_read_line_io_task(F_PORT* port);
void primitive_read_line_8(void);
bool read_count_step(F_PORT* port);

#define CAN_READ_COUNT(port,count) (untag_sbuf(port->line)->top >= count)

bool can_read_count(F_PORT* port, F_FIXNUM count);
void primitive_can_read_count(void);
void primitive_add_read_count_io_task(void);
bool perform_read_count_io_task(F_PORT* port);
void primitive_read_count_8(void);
