#include "factor.h"

/* Does not reduce to lowest terms, so should only be used by math
library implementation, to avoid breaking invariants. */
void primitive_from_fraction(void)
{
	CELL numerator, denominator;
	F_RATIO* ratio;

	maybe_garbage_collection();

	denominator = dpop();
	numerator = dpop();
	ratio = allot(sizeof(F_RATIO));
	ratio->numerator = numerator;
	ratio->denominator = denominator;
	dpush(RETAG(ratio,RATIO_TYPE));
}
