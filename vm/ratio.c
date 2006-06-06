#include "factor.h"

/* Does not reduce to lowest terms, so should only be used by math
library implementation, to avoid breaking invariants. */
void primitive_from_fraction(void)
{
	CELL numerator, denominator;
	F_RATIO* ratio;

	maybe_gc(0);

	denominator = dpop();
	numerator = dpop();
	ratio = allot_object(RATIO_TYPE,sizeof(F_RATIO));
	ratio->numerator = numerator;
	ratio->denominator = denominator;
	dpush(RETAG(ratio,RATIO_TYPE));
}

void fixup_ratio(F_RATIO* ratio)
{
	data_fixup(&ratio->numerator);
	data_fixup(&ratio->denominator);
}

void collect_ratio(F_RATIO* ratio)
{
	copy_handle(&ratio->numerator);
	copy_handle(&ratio->denominator);
}
