#include "factor.h"

void primitive_arithmetic_type(void);

CELL tag_integer(FIXNUM x);
CELL tag_cell(CELL x);
CELL to_cell(CELL x);

bool realp(CELL tagged);
void primitive_numberp(void);

bool zerop(CELL tagged);
bool onep(CELL tagged);
