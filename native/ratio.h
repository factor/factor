typedef struct {
	CELL numerator;
	CELL denominator;
} F_RATIO;

INLINE F_RATIO* untag_ratio(CELL tagged)
{
	type_check(RATIO_TYPE,tagged);
	return (F_RATIO*)UNTAG(tagged);
}

INLINE CELL tag_ratio(F_RATIO* ratio)
{
	return RETAG(ratio,RATIO_TYPE);
}

void primitive_numerator(void);
void primitive_denominator(void);
void primitive_from_fraction(void);
