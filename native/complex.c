#include "factor.h"

void primitive_from_rect(void)
{
	CELL imaginary = dpop();
	CELL real = dpop();
	F_COMPLEX* complex;

	maybe_garbage_collection();

	complex = allot(sizeof(F_COMPLEX));
	complex->real = real;
	complex->imaginary = imaginary;
	dpush(tag_complex(complex));
}
