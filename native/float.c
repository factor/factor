#include "factor.h"

void primitive_floatp(void)
{
	drepl(tag_boolean(typep(FLOAT_TYPE,dpeek())));
}

FLOAT* to_float(CELL tagged)
{
	switch(type_of(tagged))
	{
	case FIXNUM_TYPE:
		return fixnum_to_float(tagged);
	case BIGNUM_TYPE:
		return bignum_to_float(tagged);
	case RATIO_TYPE:
		return ratio_to_float(tagged);
	case FLOAT_TYPE:
		return (FLOAT*)UNTAG(tagged);
	default:
		type_error(FLOAT_TYPE,tagged);
		return NULL; /* can't happen */
	}
}

void primitive_to_float(void)
{
	drepl(tag_object(to_float(dpeek())));
}

void primitive_str_to_float(void)
{
	STRING* str = untag_string(dpeek());
	char* c_str = to_c_string(str);
	char* end = c_str;
	double f = strtod(c_str,&end);
	if(end != c_str + str->capacity)
		general_error(ERROR_FLOAT_FORMAT,tag_object(str));
	drepl(tag_object(make_float(f)));
}

void primitive_float_to_str(void)
{
	char tmp[33];
	snprintf(&tmp,32,"%.16g",to_float(dpeek())->n);
	tmp[32] = '\0';
	drepl(tag_object(from_c_string(tmp)));
}

void primitive_float_to_bits(void)
{
	double f = untag_float(dpeek());
	long long f_raw = *(long long*)&f;
	drepl(tag_object(s48_long_long_to_bignum(f_raw)));
}

CELL number_eq_float(FLOAT* x, FLOAT* y)
{
	return tag_boolean(x->n == y->n);
}

CELL add_float(FLOAT* x, FLOAT* y)
{
	return tag_object(make_float(x->n + y->n));
}

CELL subtract_float(FLOAT* x, FLOAT* y)
{
	return tag_object(make_float(x->n - y->n));
}

CELL multiply_float(FLOAT* x, FLOAT* y)
{
	return tag_object(make_float(x->n * y->n));
}

CELL divide_float(FLOAT* x, FLOAT* y)
{
	return tag_object(make_float(x->n / y->n));
}

CELL divfloat_float(FLOAT* x, FLOAT* y)
{
	return tag_object(make_float(x->n / y->n));
}

CELL less_float(FLOAT* x, FLOAT* y)
{
	return tag_boolean(x->n < y->n);
}

CELL lesseq_float(FLOAT* x, FLOAT* y)
{
	return tag_boolean(x->n <= y->n);
}

CELL greater_float(FLOAT* x, FLOAT* y)
{
	return tag_boolean(x->n > y->n);
}

CELL greatereq_float(FLOAT* x, FLOAT* y)
{
	return tag_boolean(x->n >= y->n);
}

void primitive_facos(void)
{
	drepl(tag_object(make_float(acos(to_float(dpeek())->n))));
}

void primitive_fasin(void)
{
	drepl(tag_object(make_float(asin(to_float(dpeek())->n))));
}

void primitive_fatan(void)
{
	drepl(tag_object(make_float(atan(to_float(dpeek())->n))));
}

void primitive_fatan2(void)
{
	double x = to_float(dpop())->n;
	double y = to_float(dpop())->n;
	dpush(tag_object(make_float(atan2(y,x))));
}

void primitive_fcos(void)
{
	drepl(tag_object(make_float(cos(to_float(dpeek())->n))));
}

void primitive_fexp(void)
{
	drepl(tag_object(make_float(exp(to_float(dpeek())->n))));
}

void primitive_fcosh(void)
{
	drepl(tag_object(make_float(cosh(to_float(dpeek())->n))));
}

void primitive_flog(void)
{
	drepl(tag_object(make_float(log(to_float(dpeek())->n))));
}

void primitive_fpow(void)
{
	double x = to_float(dpop())->n;
	double y = to_float(dpop())->n;
	dpush(tag_object(make_float(pow(y,x))));
}

void primitive_fsin(void)
{
	drepl(tag_object(make_float(sin(to_float(dpeek())->n))));
}

void primitive_fsinh(void)
{
	drepl(tag_object(make_float(sinh(to_float(dpeek())->n))));
}

void primitive_fsqrt(void)
{
	drepl(tag_object(make_float(sqrt(to_float(dpeek())->n))));
}
