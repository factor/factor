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

INLINE FLOAT* untag_float(CELL tagged)
{
	type_check(FLOAT_TYPE,tagged);
	return (FLOAT*)UNTAG(tagged);
}

void primitive_floatp(void);
FLOAT* to_float(CELL tagged);
void primitive_to_float(void);
void primitive_str_to_float(void);
void primitive_float_to_str(void);
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
