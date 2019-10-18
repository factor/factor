#include "factor.h"

void primitive_from_rect(void)
{
	CELL real, imaginary;
	F_COMPLEX* complex;

	maybe_garbage_collection();

	imaginary = dpop();
	real = dpop();
	complex = allot(sizeof(F_COMPLEX));
	complex->real = real;
	complex->imaginary = imaginary;
	dpush(tag_complex(complex));
}
