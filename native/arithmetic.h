#include "factor.h"

CELL upgraded_arithmetic_type(CELL type1, CELL type2);

CELL tag_fixnum_or_bignum(FIXNUM x);

#define BINARY_OP(OP) \
CELL OP(CELL x, CELL y) \
{ \
	switch(upgraded_arithmetic_type(type_of(x),type_of(y))) \
	{ \
	case FIXNUM_TYPE: \
		return OP##_fixnum(untag_fixnum_fast(x),untag_fixnum_fast(y)); \
	case BIGNUM_TYPE: \
		return OP##_bignum(to_bignum(x),to_bignum(y)); \
	case RATIO_TYPE: \
		return OP##_ratio(to_ratio(x),to_ratio(y)); \
	case FLOAT_TYPE: \
		return OP##_float(to_float(x),to_float(y)); \
	case COMPLEX_TYPE: \
		return OP##_complex(to_complex(x),to_complex(y)); \
	default: \
		return OP##_anytype(x,y); \
	} \
} \
\
void primitive_##OP(void) \
{ \
	CELL y = dpop(), x = dpop(); \
	dpush(OP(x,y)); \
}

#define BINARY_OP_FIXNUM(OP) \
CELL OP(CELL x, FIXNUM y) \
{ \
	switch(type_of(x)) \
	{ \
	case FIXNUM_TYPE: \
		return OP##_fixnum(untag_fixnum_fast(x),y); \
	case BIGNUM_TYPE: \
		return OP##_bignum((ARRAY*)UNTAG(x),y); \
	default: \
		type_error(INTEGER_TYPE,x); \
		return F; \
	} \
} \
\
void primitive_##OP(void) \
{ \
	CELL y = dpop(), x = dpop(); \
	dpush(OP(x,to_fixnum(y))); \
}

#define BINARY_OP_INTEGER_ONLY(OP) \
\
CELL OP##_ratio(RATIO* x, RATIO* y) \
{ \
	type_error(INTEGER_TYPE,tag_ratio(x)); \
	return F; \
} \
\
CELL OP##_complex(COMPLEX* x, COMPLEX* y) \
{ \
	type_error(INTEGER_TYPE,tag_complex(x)); \
	return F; \
} \
\
CELL OP##_float(FLOAT* x, FLOAT* y) \
{ \
	type_error(INTEGER_TYPE,tag_object(x)); \
	return F; \
}

#define BINARY_OP_NUMBER_ONLY(OP) \
\
CELL OP##_anytype(CELL x, CELL y) \
{ \
	type_error(NUMBER_TYPE,x); \
	return F; \
}

#define UNARY_OP(OP) \
CELL OP(CELL x) \
{ \
	switch(type_of(x)) \
	{ \
	case FIXNUM_TYPE: \
		return OP##_fixnum(untag_fixnum_fast(x)); \
	case RATIO_TYPE: \
		return OP##_ratio((RATIO*)UNTAG(x)); \
	case COMPLEX_TYPE: \
		return OP##_complex((COMPLEX*)UNTAG(x)); \
	case BIGNUM_TYPE: \
		return OP##_bignum((ARRAY*)UNTAG(x)); \
	case FLOAT_TYPE: \
		return OP##_float((FLOAT*)UNTAG(x)); \
	default: \
		return OP##_anytype(x); \
	} \
} \
\
void primitive_##OP(void) \
{ \
	drepl(OP(dpeek())); \
}

#define UNARY_OP_INTEGER_ONLY(OP) \
\
CELL OP##_ratio(RATIO* x) \
{ \
	type_error(INTEGER_TYPE,tag_ratio(x)); \
	return F; \
} \
\
CELL OP##_complex(COMPLEX* x) \
{ \
	type_error(INTEGER_TYPE,tag_complex(x)); \
	return F; \
} \
\
CELL OP##_float(FLOAT* x) \
{ \
	type_error(INTEGER_TYPE,tag_object(x)); \
	return F; \
}

#define UNARY_OP_NUMBER_ONLY(OP) \
\
CELL OP##_anytype(CELL x) \
{ \
	type_error(NUMBER_TYPE,x); \
	return F; \
}

bool realp(CELL tagged);
void primitive_numberp(void);

bool zerop(CELL tagged);

void primitive_to_fixnum(void);
void primitive_to_bignum(void);
void primitive_to_integer(void);
CELL number_eq(CELL x, CELL y);
void primitive_number_eq(void);
CELL add(CELL x, CELL y);
void primitive_add(void);
CELL subtract(CELL x, CELL y);
void primitive_subtract(void);
CELL multiply(CELL x, CELL y);
void primitive_multiply(void);
CELL divide(CELL x, CELL y);
void primitive_divmod(void);
CELL divint(CELL x, CELL y);
void primitive_divint(void);
CELL divfloat(CELL x, CELL y);
void primitive_divfloat(void);
CELL divide(CELL x, CELL y);
void primitive_divide(void);
CELL less(CELL x, CELL y);
void primitive_less(void);
CELL lesseq(CELL x, CELL y);
void primitive_lesseq(void);
CELL greater(CELL x, CELL y);
void primitive_greater(void);
CELL greatereq(CELL x, CELL y);
void primitive_greatereq(void);
CELL mod(CELL x, CELL y);
void primitive_mod(void);
CELL and(CELL x, CELL y);
void primitive_and(void);
CELL or(CELL x, CELL y);
void primitive_or(void);
CELL xor(CELL x, CELL y);
void primitive_xor(void);
CELL shift(CELL x, FIXNUM y);
void primitive_shift(void);
CELL gcd(CELL x, CELL y);
void primitive_gcd(void);
