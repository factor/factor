#include "factor.h"

void primitive_real(void)
{
	switch(type_of(dpeek()))
	{
	case FIXNUM_TYPE:
	case BIGNUM_TYPE:
	case FLOAT_TYPE:
	case RATIO_TYPE:
		/* No op */
		break;
	case COMPLEX_TYPE:
		drepl(untag_complex(dpeek())->real);
		break;
	default:
		type_error(NUMBER_TYPE,dpeek());
		break;
	}
}

void primitive_imaginary(void)
{
	switch(type_of(dpeek()))
	{
	case FIXNUM_TYPE:
	case BIGNUM_TYPE:
	case FLOAT_TYPE:
	case RATIO_TYPE:
		drepl(tag_fixnum(0));
		break;
	case COMPLEX_TYPE:
		drepl(untag_complex(dpeek())->imaginary);
		break;
	default:
		type_error(NUMBER_TYPE,dpeek());
		break;
	}
}

void primitive_from_rect(void)
{
	CELL imaginary, real;

	maybe_garbage_collection();

	imaginary = dpop();
	real = dpop();

	if(!realp(imaginary))
		type_error(REAL_TYPE,imaginary);

	if(!realp(real))
		type_error(REAL_TYPE,real);

	if(zerop(imaginary))
		dpush(real);
	else
	{
		F_COMPLEX* complex = allot(sizeof(F_COMPLEX));
		complex->real = real;
		complex->imaginary = imaginary;
		dpush(tag_complex(complex));
	}
}
