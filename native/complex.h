typedef struct {
	CELL header;
	CELL real;
	CELL imaginary;
} F_COMPLEX;

void primitive_from_rect(void);
void fixup_complex(F_COMPLEX* complex);
void collect_complex(F_COMPLEX* complex);
