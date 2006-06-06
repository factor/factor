#include "factor.h"

void primitive_from_rect(void)
{
	CELL real, imaginary;
	F_COMPLEX* complex;

	maybe_gc(sizeof(F_COMPLEX));

	imaginary = dpop();
	real = dpop();
	complex = allot_object(COMPLEX_TYPE,sizeof(F_COMPLEX));
	complex->real = real;
	complex->imaginary = imaginary;
	dpush(RETAG(complex,COMPLEX_TYPE));
}

void fixup_complex(F_COMPLEX* complex)
{
	data_fixup(&complex->real);
	data_fixup(&complex->imaginary);
}

void collect_complex(F_COMPLEX* complex)
{
	copy_handle(&complex->real);
	copy_handle(&complex->imaginary);
}
