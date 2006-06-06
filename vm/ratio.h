typedef struct {
	CELL header;
	CELL numerator;
	CELL denominator;
} F_RATIO;

void primitive_from_fraction(void);
void fixup_ratio(F_RATIO* ratio);
void collect_ratio(F_RATIO* ratio);
