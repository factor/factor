typedef struct {
	CELL numerator;
	CELL denominator;
} RATIO;

INLINE RATIO* untag_ratio(CELL tagged)
{
	type_check(RATIO_TYPE,tagged);
	return (RATIO*)UNTAG(tagged);
}

INLINE CELL tag_ratio(RATIO* ratio)
{
	return RETAG(ratio,RATIO_TYPE);
}

RATIO* ratio(CELL numerator, CELL denominator);
RATIO* to_ratio(CELL x);

void primitive_ratiop(void);
void primitive_numerator(void);
void primitive_denominator(void);
CELL number_eq_ratio(RATIO* x, RATIO* y);
CELL add_ratio(RATIO* x, RATIO* y);
CELL subtract_ratio(RATIO* x, RATIO* y);
CELL multiply_ratio(RATIO* x, RATIO* y);
CELL divide_ratio(RATIO* x, RATIO* y);
CELL divfloat_ratio(RATIO* x, RATIO* y);
CELL less_ratio(RATIO* x, RATIO* y);
CELL lesseq_ratio(RATIO* x, RATIO* y);
CELL greater_ratio(RATIO* x, RATIO* y);
CELL greatereq_ratio(RATIO* x, RATIO* y);
