#include "factor.h"

void primitive_floatp(void)
{
	check_non_empty(env.dt);
	env.dt = tag_boolean(typep(FLOAT_TYPE,env.dt));
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
	env.dt = tag_object(to_float(env.dt));
}

void primitive_str_to_float(void)
{
	STRING* str = untag_string(env.dt);
	char* c_str = to_c_string(str);
	char* end = c_str;
	double f = strtod(c_str,&end);
	if(end != c_str + str->capacity)
		general_error(ERROR_FLOAT_FORMAT,tag_object(str));
	env.dt = tag_object(make_float(f));
}

void primitive_float_to_str(void)
{
	char tmp[33];
	snprintf(&tmp,32,"%.16g",to_float(env.dt)->n);
	tmp[32] = '\0';
	env.dt = tag_object(from_c_string(tmp));
}

void primitive_float_to_bits(void)
{
	double f = untag_float(env.dt);
	BIGNUM_2 f_raw = *(BIGNUM_2*)&f;
	env.dt = tag_object(bignum(f_raw));
}

CELL number_eq_float(CELL x, CELL y)
{
	return tag_boolean(((FLOAT*)UNTAG(x))->n
		== ((FLOAT*)UNTAG(y))->n);
}

CELL add_float(CELL x, CELL y)
{
	return tag_object(make_float(((FLOAT*)UNTAG(x))->n
		+ ((FLOAT*)UNTAG(y))->n));
}

CELL subtract_float(CELL x, CELL y)
{
	return tag_object(make_float(((FLOAT*)UNTAG(x))->n
		- ((FLOAT*)UNTAG(y))->n));
}

CELL multiply_float(CELL x, CELL y)
{
	return tag_object(make_float(((FLOAT*)UNTAG(x))->n
		* ((FLOAT*)UNTAG(y))->n));
}

CELL divide_float(CELL x, CELL y)
{
	return tag_object(make_float(((FLOAT*)UNTAG(x))->n
		/ ((FLOAT*)UNTAG(y))->n));
}

CELL divfloat_float(CELL x, CELL y)
{
	return tag_object(make_float(((FLOAT*)UNTAG(x))->n
		/ ((FLOAT*)UNTAG(y))->n));
}

CELL less_float(CELL x, CELL y)
{
	return tag_boolean(((FLOAT*)UNTAG(x))->n
		< ((FLOAT*)UNTAG(y))->n);
}

CELL lesseq_float(CELL x, CELL y)
{
	return tag_boolean(((FLOAT*)UNTAG(x))->n
		<= ((FLOAT*)UNTAG(y))->n);
}

CELL greater_float(CELL x, CELL y)
{
	return tag_boolean(((FLOAT*)UNTAG(x))->n
		> ((FLOAT*)UNTAG(y))->n);
}

CELL greatereq_float(CELL x, CELL y)
{
	return tag_boolean(((FLOAT*)UNTAG(x))->n
		>= ((FLOAT*)UNTAG(y))->n);
}

void primitive_facos(void)
{
	env.dt = tag_object(make_float(acos(to_float(env.dt)->n)));
}

void primitive_fasin(void)
{
	env.dt = tag_object(make_float(asin(to_float(env.dt)->n)));
}

void primitive_fatan(void)
{
	env.dt = tag_object(make_float(atan(to_float(env.dt)->n)));
}

void primitive_fatan2(void)
{
	double x = to_float(env.dt)->n;
	double y = to_float(dpop())->n;
	env.dt = tag_object(make_float(atan2(y,x)));
}

void primitive_fcos(void)
{
	env.dt = tag_object(make_float(cos(to_float(env.dt)->n)));
}

void primitive_fexp(void)
{
	env.dt = tag_object(make_float(exp(to_float(env.dt)->n)));
}

void primitive_fcosh(void)
{
	env.dt = tag_object(make_float(cosh(to_float(env.dt)->n)));
}

void primitive_flog(void)
{
	env.dt = tag_object(make_float(log(to_float(env.dt)->n)));
}

void primitive_fpow(void)
{
	double x = to_float(env.dt)->n;
	double y = to_float(dpop())->n;
	env.dt = tag_object(make_float(pow(y,x)));
}

void primitive_fsin(void)
{
	env.dt = tag_object(make_float(sin(to_float(env.dt)->n)));
}

void primitive_fsinh(void)
{
	env.dt = tag_object(make_float(sinh(to_float(env.dt)->n)));
}

void primitive_fsqrt(void)
{
	env.dt = tag_object(make_float(sqrt(to_float(env.dt)->n)));
}
