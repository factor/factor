#include "factor.h"

COMPLEX* complex(CELL real, CELL imaginary)
{
	COMPLEX* complex = allot(sizeof(COMPLEX));
	complex->real = real;
	complex->imaginary = imaginary;
	return complex;
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
		type_error(COMPLEX_TYPE,dpeek());
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
		type_error(COMPLEX_TYPE,dpeek());
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

CELL number_eq_complex(CELL x, CELL y)
{
	COMPLEX* cx = (COMPLEX*)UNTAG(x);
	COMPLEX* cy = (COMPLEX*)UNTAG(y);
	return tag_boolean(
		untag_boolean(number_eq(cx->real,cy->real)) &&
		untag_boolean(number_eq(cx->imaginary,cy->imaginary)));
}

CELL add_complex(CELL x, CELL y)
{
	COMPLEX* cx = (COMPLEX*)UNTAG(x);
	COMPLEX* cy = (COMPLEX*)UNTAG(y);
	return possibly_complex(
		add(cx->real,cy->real),
		add(cx->imaginary,cy->imaginary));
}

CELL subtract_complex(CELL x, CELL y)
{
	COMPLEX* cx = (COMPLEX*)UNTAG(x);
	COMPLEX* cy = (COMPLEX*)UNTAG(y);
	return possibly_complex(
		subtract(cx->real,cy->real),
		subtract(cx->imaginary,cy->imaginary));
}

CELL multiply_complex(CELL x, CELL y)
{
	COMPLEX* cx = (COMPLEX*)UNTAG(x);
	COMPLEX* cy = (COMPLEX*)UNTAG(y);
	return possibly_complex(
		subtract(
			multiply(cx->real,cy->real),
			multiply(cx->imaginary,cy->imaginary)),
		add(
			multiply(cx->real,cy->imaginary),
			multiply(cx->imaginary,cy->real)));
}

#define COMPLEX_DIVIDE(x,y) \
	COMPLEX* cx = (COMPLEX*)UNTAG(x); \
	COMPLEX* cy = (COMPLEX*)UNTAG(y); \
\
	CELL mag = add( \
		multiply(cy->real,cy->real), \
		multiply(cy->imaginary,cy->imaginary)); \
\
	CELL r = add( \
		multiply(cx->real,cy->real), \
		multiply(cx->imaginary,cy->imaginary)); \
	CELL i = subtract( \
		multiply(cx->imaginary,cy->real), \
		multiply(cx->real,cy->imaginary));

CELL divide_complex(CELL x, CELL y)
{
	COMPLEX_DIVIDE(x,y);
	return possibly_complex(divide(r,mag),divide(i,mag));
}

CELL divfloat_complex(CELL x, CELL y)
{
	COMPLEX_DIVIDE(x,y);
	return possibly_complex(divfloat(r,mag),divfloat(i,mag));
}

CELL less_complex(CELL x, CELL y)
{
	general_error(ERROR_INCOMPARABLE,tag_cons(cons(x,y)));
	return F;
}

CELL lesseq_complex(CELL x, CELL y)
{
	general_error(ERROR_INCOMPARABLE,tag_cons(cons(x,y)));
	return F;
}

CELL greater_complex(CELL x, CELL y)
{
	general_error(ERROR_INCOMPARABLE,tag_cons(cons(x,y)));
	return F;
}

CELL greatereq_complex(CELL x, CELL y)
{
	general_error(ERROR_INCOMPARABLE,tag_cons(cons(x,y)));
	return F;
}
