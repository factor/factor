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
	maybe_garbage_collection();
	drepl(tag_object(make_float(to_float(dpeek()))));
}

void primitive_str_to_float(void)
{
	STRING* str;
	char *c_str, *end;
	double f;

	maybe_garbage_collection();

	str = untag_string(dpeek());
	c_str = to_c_string(str);
	end = c_str;
	f = strtod(c_str,&end);
	if(end != c_str + str->capacity)
		general_error(ERROR_FLOAT_FORMAT,tag_object(str));
	drepl(tag_object(make_float(f)));
}

void primitive_float_to_str(void)
{
	char tmp[33];

	maybe_garbage_collection();

	snprintf(tmp,32,"%.16g",to_float(dpop()));
	tmp[32] = '\0';
	box_c_string(tmp);
}

void primitive_float_to_bits(void)
{
	double f;
	long long f_raw;

	maybe_garbage_collection();

	f = untag_float(dpeek());
	f_raw = *(long long*)&f;
	drepl(tag_object(s48_long_long_to_bignum(f_raw)));
}

#define GC_AND_POP_FLOATS(x,y) \
	double x, y; \
	maybe_garbage_collection(); \
	y = to_float(dpop()); \
	x = to_float(dpop());

void primitive_float_eq(void)
{
	GC_AND_POP_FLOATS(x,y);
	box_boolean(x == y);
}

void primitive_float_add(void)
{
	GC_AND_POP_FLOATS(x,y);
	dpush(tag_object(make_float(x + y)));
}

void primitive_float_subtract(void)
{
	GC_AND_POP_FLOATS(x,y);
	dpush(tag_object(make_float(x - y)));
}

void primitive_float_multiply(void)
{
	GC_AND_POP_FLOATS(x,y);
	dpush(tag_object(make_float(x * y)));
}

void primitive_float_divfloat(void)
{
	GC_AND_POP_FLOATS(x,y);
	dpush(tag_object(make_float(x / y)));
}

void primitive_float_less(void)
{
	GC_AND_POP_FLOATS(x,y);
	box_boolean(x < y);
}

void primitive_float_lesseq(void)
{
	GC_AND_POP_FLOATS(x,y);
	box_boolean(x <= y);
}

void primitive_float_greater(void)
{
	GC_AND_POP_FLOATS(x,y);
	box_boolean(x > y);
}

void primitive_float_greatereq(void)
{
	GC_AND_POP_FLOATS(x,y);
	box_boolean(x >= y);
}

void primitive_facos(void)
{
	maybe_garbage_collection();
	drepl(tag_object(make_float(acos(to_float(dpeek())))));
}

void primitive_fasin(void)
{
	maybe_garbage_collection();
	drepl(tag_object(make_float(asin(to_float(dpeek())))));
}

void primitive_fatan(void)
{
	maybe_garbage_collection();
	drepl(tag_object(make_float(atan(to_float(dpeek())))));
}

void primitive_fatan2(void)
{
	GC_AND_POP_FLOATS(x,y);
	dpush(tag_object(make_float(atan2(x,y))));
}

void primitive_fcos(void)
{
	maybe_garbage_collection();
	drepl(tag_object(make_float(cos(to_float(dpeek())))));
}

void primitive_fexp(void)
{
	maybe_garbage_collection();
	drepl(tag_object(make_float(exp(to_float(dpeek())))));
}

void primitive_fcosh(void)
{
	maybe_garbage_collection();
	drepl(tag_object(make_float(cosh(to_float(dpeek())))));
}

void primitive_flog(void)
{
	maybe_garbage_collection();
	drepl(tag_object(make_float(log(to_float(dpeek())))));
}

void primitive_fpow(void)
{
	GC_AND_POP_FLOATS(x,y);
	dpush(tag_object(make_float(pow(x,y))));
}

void primitive_fsin(void)
{
	maybe_garbage_collection();
	drepl(tag_object(make_float(sin(to_float(dpeek())))));
}

void primitive_fsinh(void)
{
	maybe_garbage_collection();
	drepl(tag_object(make_float(sinh(to_float(dpeek())))));
}

void primitive_fsqrt(void)
{
	maybe_garbage_collection();
	drepl(tag_object(make_float(sqrt(to_float(dpeek())))));
}
