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
	check_non_empty(env.dt);
	env.dt = tag_boolean(typep(COMPLEX_TYPE,env.dt));
}

void primitive_real(void)
{
	switch(type_of(env.dt))
	{
	case FIXNUM_TYPE:
	case BIGNUM_TYPE:
	case FLOAT_TYPE:
	case RATIO_TYPE:
		/* No op */
		break;
	case COMPLEX_TYPE:
		env.dt = untag_complex(env.dt)->real;
		break;
	default:
		type_error(COMPLEX_TYPE,env.dt);
		break;
	}
}

void primitive_imaginary(void)
{
	switch(type_of(env.dt))
	{
	case FIXNUM_TYPE:
	case BIGNUM_TYPE:
	case FLOAT_TYPE:
	case RATIO_TYPE:
		env.dt = tag_fixnum(0);
		break;
	case COMPLEX_TYPE:
		env.dt = untag_complex(env.dt)->imaginary;
		break;
	default:
		type_error(COMPLEX_TYPE,env.dt);
		break;
	}
}

void primitive_to_rect(void)
{
	COMPLEX* c;
	switch(type_of(env.dt))
	{
	case FIXNUM_TYPE:
	case BIGNUM_TYPE:
	case FLOAT_TYPE:
	case RATIO_TYPE:
		dpush(env.dt);
		env.dt = tag_fixnum(0);
		break;
	case COMPLEX_TYPE:
		c = untag_complex(env.dt);
		env.dt = c->imaginary;
		dpush(c->real);
		break;
	default:
		type_error(COMPLEX_TYPE,env.dt);
		break;
	}
}

void primitive_from_rect(void)
{
	CELL imaginary = env.dt;
	CELL real = dpop();
	check_non_empty(imaginary);
	check_non_empty(real);

	if(!realp(imaginary))
		type_error(REAL_TYPE,imaginary);

	if(!realp(real))
		type_error(REAL_TYPE,real);

	env.dt = possibly_complex(real,imaginary);
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
		add(cx->imaginary,cy->real));
}

CELL subtract_complex(CELL x, CELL y)
{
	COMPLEX* cx = (COMPLEX*)UNTAG(x);
	COMPLEX* cy = (COMPLEX*)UNTAG(y);
	return possibly_complex(
		subtract(cx->real,cy->real),
		subtract(cx->imaginary,cy->real));
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
