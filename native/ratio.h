typedef struct {
	CELL numerator;
	CELL denominator;
} F_RATIO;

INLINE CELL tag_ratio(F_RATIO* ratio)
{
	return RETAG(ratio,RATIO_TYPE);
}

void primitive_from_fraction(void);
