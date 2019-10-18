#include "factor.h"

double to_float(CELL tagged)
{
	F_RATIO* r;
	double x;
	double y;

	switch(TAG(tagged))
	{
	case FIXNUM_TYPE:
		return (double)untag_fixnum_fast(tagged);
	case BIGNUM_TYPE:
		return s48_bignum_to_double((F_ARRAY*)UNTAG(tagged));
	case RATIO_TYPE:
		r = (F_RATIO*)UNTAG(tagged);
		x = to_float(r->numerator);
		y = to_float(r->denominator);
		return x / y;
	case FLOAT_TYPE:
		return ((F_FLOAT*)UNTAG(tagged))->n;
	default:
		type_error(FLOAT_TYPE,tagged);
		return 0.0; /* can't happen */
	}
}

void primitive_to_float(void)
{
	maybe_garbage_collection();
	drepl(tag_float(to_float(dpeek())));
}

void primitive_str_to_float(void)
{
	F_STRING* str;
	char *c_str, *end;
	double f;

	maybe_garbage_collection();

	str = untag_string(dpeek());
	c_str = to_c_string(str);
	end = c_str;
	f = strtod(c_str,&end);
	if(end != c_str + string_capacity(str))
		general_error(ERROR_FLOAT_FORMAT,tag_object(str));
	drepl(tag_float(f));
}

void primitive_float_to_str(void)
{
	char tmp[33];

	maybe_garbage_collection();

	snprintf(tmp,32,"%.16g",to_float(dpop()));
	tmp[32] = '\0';
	box_c_string(tmp);
}

#define GC_AND_POP_FLOATS(x,y) \
	double x, y; \
	maybe_garbage_collection(); \
	y = untag_float_fast(dpop()); \
	x = untag_float_fast(dpop());

void primitive_float_eq(void)
{
	GC_AND_POP_FLOATS(x,y);
	box_boolean(x == y);
}

void primitive_float_add(void)
{
	GC_AND_POP_FLOATS(x,y);
	dpush(tag_float(x + y));
}

void primitive_float_subtract(void)
{
	GC_AND_POP_FLOATS(x,y);
	dpush(tag_float(x - y));
}

void primitive_float_multiply(void)
{
	GC_AND_POP_FLOATS(x,y);
	dpush(tag_float(x * y));
}

void primitive_float_divfloat(void)
{
	GC_AND_POP_FLOATS(x,y);
	dpush(tag_float(x / y));
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
	drepl(tag_float(acos(to_float(dpeek()))));
}

void primitive_fasin(void)
{
	maybe_garbage_collection();
	drepl(tag_float(asin(to_float(dpeek()))));
}

void primitive_fatan(void)
{
	maybe_garbage_collection();
	drepl(tag_float(atan(to_float(dpeek()))));
}

void primitive_fatan2(void)
{
	double x, y;
	maybe_garbage_collection();
	y = to_float(dpop());
	x = to_float(dpop());
	dpush(tag_float(atan2(x,y)));
}

void primitive_fcos(void)
{
	maybe_garbage_collection();
	drepl(tag_float(cos(to_float(dpeek()))));
}

void primitive_fexp(void)
{
	maybe_garbage_collection();
	drepl(tag_float(exp(to_float(dpeek()))));
}

void primitive_fcosh(void)
{
	maybe_garbage_collection();
	drepl(tag_float(cosh(to_float(dpeek()))));
}

void primitive_flog(void)
{
	maybe_garbage_collection();
	drepl(tag_float(log(to_float(dpeek()))));
}

void primitive_fpow(void)
{
	double x, y;
	maybe_garbage_collection();
	y = to_float(dpop());
	x = to_float(dpop());
	dpush(tag_float(pow(x,y)));
}

void primitive_fsin(void)
{
	maybe_garbage_collection();
	drepl(tag_float(sin(to_float(dpeek()))));
}

void primitive_fsinh(void)
{
	maybe_garbage_collection();
	drepl(tag_float(sinh(to_float(dpeek()))));
}

void primitive_fsqrt(void)
{
	maybe_garbage_collection();
	drepl(tag_float(sqrt(to_float(dpeek()))));
}
