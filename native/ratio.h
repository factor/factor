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

void primitive_ratiop(void);
void primitive_numerator(void);
void primitive_denominator(void);
CELL number_eq_ratio(CELL x, CELL y);
CELL add_ratio(CELL x, CELL y);
CELL subtract_ratio(CELL x, CELL y);
CELL multiply_ratio(CELL x, CELL y);
CELL divide_ratio(CELL x, CELL y);
CELL divfloat_ratio(CELL x, CELL y);
CELL less_ratio(CELL x, CELL y);
CELL lesseq_ratio(CELL x, CELL y);
CELL greater_ratio(CELL x, CELL y);
CELL greatereq_ratio(CELL x, CELL y);
