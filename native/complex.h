typedef struct {
	CELL real;
	CELL imaginary;
} COMPLEX;

INLINE COMPLEX* untag_complex(CELL tagged)
{
	type_check(COMPLEX_TYPE,tagged);
	return (COMPLEX*)UNTAG(tagged);
}

INLINE CELL tag_complex(COMPLEX* complex)
{
	return RETAG(complex,COMPLEX_TYPE);
}

void primitive_real(void);
void primitive_imaginary(void);
void primitive_to_rect(void);
void primitive_from_rect(void);
