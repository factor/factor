typedef struct {
	CELL header;
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

FLOAT* to_float(CELL tagged);
void primitive_to_float(void);
void primitive_str_to_float(void);
void primitive_float_to_str(void);
void primitive_float_to_bits(void);

CELL number_eq_float(FLOAT* x, FLOAT* y);
CELL add_float(FLOAT* x, FLOAT* y);
CELL subtract_float(FLOAT* x, FLOAT* y);
CELL multiply_float(FLOAT* x, FLOAT* y);
CELL divide_float(FLOAT* x, FLOAT* y);
CELL divfloat_float(FLOAT* x, FLOAT* y);
CELL less_float(FLOAT* x, FLOAT* y);
CELL lesseq_float(FLOAT* x, FLOAT* y);
CELL greater_float(FLOAT* x, FLOAT* y);
CELL greatereq_float(FLOAT* x, FLOAT* y);

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
