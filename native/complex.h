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

COMPLEX* complex(CELL real, CELL imaginary);
COMPLEX* to_complex(CELL x);
CELL possibly_complex(CELL real, CELL imaginary);

void primitive_complexp(void);
void primitive_real(void);
void primitive_imaginary(void);
void primitive_to_rect(void);
void primitive_from_rect(void);
CELL number_eq_complex(COMPLEX* x, COMPLEX* y);
CELL add_complex(COMPLEX* x, COMPLEX* y);
CELL subtract_complex(COMPLEX* x, COMPLEX* y);
CELL multiply_complex(COMPLEX* x, COMPLEX* y);
CELL divide_complex(COMPLEX* x, COMPLEX* y);
CELL divfloat_complex(COMPLEX* x, COMPLEX* y);
CELL less_complex(COMPLEX* x, COMPLEX* y);
CELL lesseq_complex(COMPLEX* x, COMPLEX* y);
CELL greater_complex(COMPLEX* x, COMPLEX* y);
CELL greatereq_complex(COMPLEX* x, COMPLEX* y);
