#include "factor.h"

/* Does not reduce to lowest terms, so should only be used by math
library implementation, to avoid breaking invariants. */
void primitive_from_fraction(void)
{
	CELL denominator = dpop();
	CELL numerator = dpop();
	F_RATIO* ratio;

	maybe_garbage_collection();

	ratio = allot(sizeof(F_RATIO));
	ratio->numerator = numerator;
	ratio->denominator = denominator;
	dpush(tag_ratio(ratio));
}
