#include "factor.h"

COMPLEX* complex(CELL real, CELL imaginary)
{
	COMPLEX* complex = allot(sizeof(COMPLEX));
	complex->real = real;
	complex->imaginary = imaginary;
	return complex;
}

COMPLEX* to_complex(CELL x)
{
	switch(type_of(x))
	{
	case FIXNUM_TYPE:
	case BIGNUM_TYPE:
	case FLOAT_TYPE:
	case RATIO_TYPE:
		return complex(x,0);
	case COMPLEX_TYPE:
		return (COMPLEX*)UNTAG(x);
	default:
		type_error(NUMBER_TYPE,x);
		return NULL;
	}
}

CELL possibly_complex(CELL real, CELL imaginary)
{
	if(zerop(imaginary))
		return real;
	else
		return tag_complex(complex(real,imaginary));
}

void primitive_complexp(void)
{
	drepl(tag_boolean(typep(COMPLEX_TYPE,dpeek())));
}

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

void primitive_to_rect(void)
{
	COMPLEX* c;
	switch(type_of(dpeek()))
	{
	case FIXNUM_TYPE:
	case BIGNUM_TYPE:
	case FLOAT_TYPE:
	case RATIO_TYPE:
		dpush(tag_fixnum(0));
		break;
	case COMPLEX_TYPE:
		c = untag_complex(dpop());
		dpush(c->real);
		dpush(c->imaginary);
		break;
	default:
		type_error(NUMBER_TYPE,dpeek());
		break;
	}
}

void primitive_from_rect(void)
{
	CELL imaginary = dpop();
	CELL real = dpop();

	if(!realp(imaginary))
		type_error(REAL_TYPE,imaginary);

	if(!realp(real))
		type_error(REAL_TYPE,real);

	dpush(possibly_complex(real,imaginary));
}

CELL number_eq_complex(COMPLEX* x, COMPLEX* y)
{
	return tag_boolean(
		untag_boolean(number_eq(x->real,y->real)) &&
		untag_boolean(number_eq(x->imaginary,y->imaginary)));
}

CELL add_complex(COMPLEX* x, COMPLEX* y)
{
	return possibly_complex(
		add(x->real,y->real),
		add(x->imaginary,y->imaginary));
}

CELL subtract_complex(COMPLEX* x, COMPLEX* y)
{
	return possibly_complex(
		subtract(x->real,y->real),
		subtract(x->imaginary,y->imaginary));
}

CELL multiply_complex(COMPLEX* x, COMPLEX* y)
{
	return possibly_complex(
		subtract(
			multiply(x->real,y->real),
			multiply(x->imaginary,y->imaginary)),
		add(
			multiply(x->real,y->imaginary),
			multiply(x->imaginary,y->real)));
}

#define COMPLEX_DIVIDE(x,y) \
\
	CELL mag = add( \
		multiply(y->real,y->real), \
		multiply(y->imaginary,y->imaginary)); \
\
	CELL r = add( \
		multiply(x->real,y->real), \
		multiply(x->imaginary,y->imaginary)); \
	CELL i = subtract( \
		multiply(x->imaginary,y->real), \
		multiply(x->real,y->imaginary));

CELL divide_complex(COMPLEX* x, COMPLEX* y)
{
	COMPLEX_DIVIDE(x,y);
	return possibly_complex(divide(r,mag),divide(i,mag));
}

CELL divfloat_complex(COMPLEX* x, COMPLEX* y)
{
	COMPLEX_DIVIDE(x,y);
	return possibly_complex(divfloat(r,mag),divfloat(i,mag));
}

#define INCOMPARABLE(x,y) general_error(ERROR_INCOMPARABLE, \
	tag_cons(cons(RETAG(x,COMPLEX_TYPE),RETAG(y,COMPLEX_TYPE))));

CELL less_complex(COMPLEX* x, COMPLEX* y)
{
	INCOMPARABLE(x,y);
	return F;
}

CELL lesseq_complex(COMPLEX* x, COMPLEX* y)
{
	INCOMPARABLE(x,y);
	return F;
}

CELL greater_complex(COMPLEX* x, COMPLEX* y)
{
	INCOMPARABLE(x,y);
	return F;
}

CELL greatereq_complex(COMPLEX* x, COMPLEX* y)
{
	INCOMPARABLE(x,y);
	return F;
}
