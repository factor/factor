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

void primitive_numerator(void);
void primitive_denominator(void);
void primitive_from_fraction(void);
void primitive_to_fraction(void);
