typedef struct {
	CELL header;
/* FIXME */
#ifndef FACTOR_64
	CELL alignment;
#endif
	double n;
} FLOAT;

INLINE FLOAT* make_float(double n)
{
	FLOAT* flo = allot_object(FLOAT_TYPE,sizeof(FLOAT));
	flo->n = n;
	return flo;
}

INLINE double untag_float_fast(CELL tagged)
{
	return ((FLOAT*)UNTAG(tagged))->n;
}

INLINE double untag_float(CELL tagged)
{
	type_check(FLOAT_TYPE,tagged);
	return untag_float_fast(tagged);
}

void primitive_floatp(void);
FLOAT* to_float(CELL tagged);
void primitive_to_float(void);
void primitive_str_to_float(void);
void primitive_float_to_str(void);
void primitive_float_to_bits(void);

CELL number_eq_float(CELL x, CELL y);
CELL add_float(CELL x, CELL y);
CELL subtract_float(CELL x, CELL y);
CELL multiply_float(CELL x, CELL y);
CELL divide_float(CELL x, CELL y);
CELL divfloat_float(CELL x, CELL y);
CELL less_float(CELL x, CELL y);
CELL lesseq_float(CELL x, CELL y);
CELL greater_float(CELL x, CELL y);
CELL greatereq_float(CELL x, CELL y);

void primitive_facos(void);
void primitive_fasin(void);
void primitive_fatan(void);
void primitive_fatan2(void);
void primitive_fcos(void);
void primitive_fexp(void);
void primitive_fcosh(void);
void primitive_flog(void);
void primitive_fpow(void);
void primitive_fsin(void);
void primitive_fsinh(void);
void primitive_fsqrt(void);
