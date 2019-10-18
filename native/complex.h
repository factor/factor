typedef struct {
	CELL real;
	CELL imaginary;
} F_COMPLEX;

INLINE F_COMPLEX* untag_complex(CELL tagged)
{
	type_check(COMPLEX_TYPE,tagged);
	return (F_COMPLEX*)UNTAG(tagged);
}

INLINE CELL tag_complex(F_COMPLEX* complex)
{
	return RETAG(complex,COMPLEX_TYPE);
}

void primitive_real(void);
void primitive_imaginary(void);
void primitive_from_rect(void);
