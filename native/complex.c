#include "factor.h"

void primitive_from_rect(void)
{
	CELL real, imaginary;
	F_CONS* complex;

	maybe_garbage_collection();

	imaginary = dpop();
	real = dpop();
	complex = allot(sizeof(F_CONS));
	complex->car = real;
	complex->cdr = imaginary;
	dpush(RETAG(complex,COMPLEX_TYPE));
}
