typedef struct {
	CELL real;
	CELL imaginary;
} F_COMPLEX;

INLINE CELL tag_complex(F_COMPLEX* complex)
{
	return RETAG(complex,COMPLEX_TYPE);
}

void primitive_from_rect(void);
