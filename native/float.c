#include "factor.h"

double to_float(CELL tagged)
{
	RATIO* r;
	double x;
	double y;

	switch(type_of(tagged))
	{
	case FIXNUM_TYPE:
		return (double)untag_fixnum_fast(tagged);
	case BIGNUM_TYPE:
		return s48_bignum_to_double((ARRAY*)UNTAG(tagged));
	case RATIO_TYPE:
		r = (RATIO*)UNTAG(tagged);
		x = to_float(r->numerator);
		y = to_float(r->denominator);
		return x / y;
	case FLOAT_TYPE:
		return ((FLOAT*)UNTAG(tagged))->n;
	default:
		type_error(FLOAT_TYPE,tagged);
		return 0.0; /* can't happen */
	}
}

void primitive_to_float(void)
{
	drepl(tag_object(make_float(to_float(dpeek()))));
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
	snprintf(tmp,32,"%.16g",to_float(dpeek()));
	tmp[32] = '\0';
	drepl(tag_object(from_c_string(tmp)));
}

void primitive_float_to_bits(void)
{
	double f = untag_float(dpeek());
	long long f_raw = *(long long*)&f;
	drepl(tag_object(s48_long_long_to_bignum(f_raw)));
}

void primitive_float_eq(void)
{
	double y = to_float(dpop());
	double x = to_float(dpop());
	dpush(tag_boolean(x == y));
}

void primitive_float_add(void)
{
	double y = to_float(dpop());
	double x = to_float(dpop());
	dpush(tag_object(make_float(x + y)));
}

void primitive_float_subtract(void)
{
	double y = to_float(dpop());
	double x = to_float(dpop());
	dpush(tag_object(make_float(x - y)));
}

void primitive_float_multiply(void)
{
	double y = to_float(dpop());
	double x = to_float(dpop());
	dpush(tag_object(make_float(x * y)));
}

void primitive_float_divfloat(void)
{
	double y = to_float(dpop());
	double x = to_float(dpop());
	dpush(tag_object(make_float(x / y)));
}

void primitive_float_less(void)
{
	double y = to_float(dpop());
	double x = to_float(dpop());
	dpush(tag_boolean(x < y));
}

void primitive_float_lesseq(void)
{
	double y = to_float(dpop());
	double x = to_float(dpop());
	dpush(tag_boolean(x <= y));
}

void primitive_float_greater(void)
{
	double y = to_float(dpop());
	double x = to_float(dpop());
	dpush(tag_boolean(x > y));
}

void primitive_float_greatereq(void)
{
	double y = to_float(dpop());
	double x = to_float(dpop());
	dpush(tag_boolean(x >= y));
}

void primitive_facos(void)
{
	drepl(tag_object(make_float(acos(to_float(dpeek())))));
}

void primitive_fasin(void)
{
	drepl(tag_object(make_float(asin(to_float(dpeek())))));
}

void primitive_fatan(void)
{
	drepl(tag_object(make_float(atan(to_float(dpeek())))));
}

void primitive_fatan2(void)
{
	double x = to_float(dpop());
	double y = to_float(dpop());
	dpush(tag_object(make_float(atan2(y,x))));
}

void primitive_fcos(void)
{
	drepl(tag_object(make_float(cos(to_float(dpeek())))));
}

void primitive_fexp(void)
{
	drepl(tag_object(make_float(exp(to_float(dpeek())))));
}

void primitive_fcosh(void)
{
	drepl(tag_object(make_float(cosh(to_float(dpeek())))));
}

void primitive_flog(void)
{
	drepl(tag_object(make_float(log(to_float(dpeek())))));
}

void primitive_fpow(void)
{
	double x = to_float(dpop());
	double y = to_float(dpop());
	dpush(tag_object(make_float(pow(y,x))));
}

void primitive_fsin(void)
{
	drepl(tag_object(make_float(sin(to_float(dpeek())))));
}

void primitive_fsinh(void)
{
	drepl(tag_object(make_float(sinh(to_float(dpeek())))));
}

void primitive_fsqrt(void)
{
	drepl(tag_object(make_float(sqrt(to_float(dpeek())))));
}
