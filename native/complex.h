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
CELL possibly_complex(CELL real, CELL imaginary);

void primitive_complexp(void);
void primitive_real(void);
void primitive_imaginary(void);
void primitive_to_rect(void);
void primitive_from_rect(void);
CELL number_eq_complex(CELL x, CELL y);
CELL add_complex(CELL x, CELL y);
CELL subtract_complex(CELL x, CELL y);
CELL multiply_complex(CELL x, CELL y);
CELL divide_complex(CELL x, CELL y);
CELL divfloat_complex(CELL x, CELL y);
CELL less_complex(CELL x, CELL y);
CELL lesseq_complex(CELL x, CELL y);
CELL greater_complex(CELL x, CELL y);
CELL greatereq_complex(CELL x, CELL y);
