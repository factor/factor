#include "factor.h"

BIGNUM* fixnum_to_bignum(CELL n);
RATIO* fixnum_to_ratio(CELL n);
FLOAT* fixnum_to_float(CELL n);
FIXNUM bignum_to_fixnum(CELL tagged);
RATIO* bignum_to_ratio(CELL n);
FLOAT* bignum_to_float(CELL n);
FLOAT* ratio_to_float(CELL n);

#define CELL_TO_INTEGER(result) \
	FIXNUM _result = (result); \
	if(_result < FIXNUM_MIN || _result > FIXNUM_MAX) \
		return tag_object(fixnum_to_bignum(_result)); \
	else \
		return tag_fixnum(_result);

#define BIGNUM_2_TO_INTEGER(result) \
        BIGNUM_2 _result = (result); \
        if(_result < FIXNUM_MIN || _result > FIXNUM_MAX) \
                return tag_object(bignum(_result)); \
        else \
                return tag_fixnum(_result);

#define BINARY_OP(OP,anytype,integerOnly) \
CELL OP(CELL x, CELL y) \
{ \
	switch(type_of(x)) \
	{ \
	case FIXNUM_TYPE: \
\
		switch(type_of(y)) \
		{ \
		case FIXNUM_TYPE: \
			return OP##_fixnum(x,y); \
		case RATIO_TYPE: \
			if(integerOnly) \
			{ \
				type_error(INTEGER_TYPE,y); \
				return F; \
			} \
			else \
				return OP##_ratio((CELL)fixnum_to_ratio(x),y); \
		case COMPLEX_TYPE: \
			if(integerOnly) \
			{ \
				type_error(INTEGER_TYPE,y); \
				return F; \
			} \
			else \
				return OP##_complex((CELL)complex(x,tag_fixnum(0)),y); \
		case BIGNUM_TYPE: \
			return OP##_bignum((CELL)fixnum_to_bignum(x),y); \
		case FLOAT_TYPE: \
			if(integerOnly) \
			{ \
				type_error(INTEGER_TYPE,y); \
				return F; \
			} \
			else \
				return OP##_float((CELL)fixnum_to_float(x),y); \
		default: \
			if(anytype) \
				return OP##_anytype(x,y); \
			else \
			{ \
				type_error(NUMBER_TYPE,x); \
				return F; \
			} \
		} \
\
	case RATIO_TYPE: \
\
		if(integerOnly) \
		{ \
			type_error(INTEGER_TYPE,x); \
			return F; \
		} \
\
		switch(type_of(y)) \
		{ \
		case FIXNUM_TYPE: \
			return OP##_ratio(x,(CELL)fixnum_to_ratio(y)); \
		case RATIO_TYPE: \
			return OP##_ratio(x,y); \
		case COMPLEX_TYPE: \
			return OP##_complex((CELL)complex(x,tag_fixnum(0)),y); \
		case BIGNUM_TYPE: \
			return OP##_ratio(x,(CELL)bignum_to_ratio(y)); \
		case FLOAT_TYPE: \
			return OP##_float((CELL)ratio_to_float(x),y); \
		default: \
			if(anytype) \
				return OP##_anytype(x,y); \
			else \
			{ \
				type_error(NUMBER_TYPE,x); \
				return F; \
			} \
		} \
\
	case COMPLEX_TYPE: \
\
		if(integerOnly) \
		{ \
			type_error(INTEGER_TYPE,x); \
			return F; \
		} \
\
		switch(type_of(y)) \
		{ \
		case FIXNUM_TYPE: \
			return OP##_complex(x,(CELL)complex(y,tag_fixnum(0))); \
		case RATIO_TYPE: \
			return OP##_complex(x,(CELL)complex(y,tag_fixnum(0))); \
		case COMPLEX_TYPE: \
			return OP##_complex(x,y); \
		case BIGNUM_TYPE: \
			return OP##_complex(x,(CELL)complex(y,tag_fixnum(0))); \
		case FLOAT_TYPE: \
			return OP##_complex(x,(CELL)complex(y,tag_fixnum(0))); \
		default: \
			if(anytype) \
				return OP##_anytype(x,y); \
			else \
			{ \
				type_error(NUMBER_TYPE,x); \
				return F; \
			} \
		} \
\
	case BIGNUM_TYPE: \
	 \
		switch(type_of(y)) \
		{ \
		case FIXNUM_TYPE: \
			return OP##_bignum(x,(CELL)fixnum_to_bignum(y)); \
		case RATIO_TYPE: \
			if(integerOnly) \
			{ \
				type_error(INTEGER_TYPE,y); \
				return F; \
			} \
			else \
				return OP##_ratio((CELL)bignum_to_ratio(x),y); \
		case COMPLEX_TYPE: \
			if(integerOnly) \
			{ \
				type_error(INTEGER_TYPE,y); \
				return F; \
			} \
			else \
				return OP##_complex((CELL)complex(x,tag_fixnum(0)),y); \
		case BIGNUM_TYPE: \
			return OP##_bignum(x,y); \
		case FLOAT_TYPE: \
			if(integerOnly) \
			{ \
				type_error(INTEGER_TYPE,y); \
				return F; \
			} \
			else \
				return OP##_float((CELL)bignum_to_float(x),y); \
		default: \
			if(anytype) \
				return OP##_anytype(x,y); \
			else \
			{ \
				type_error(NUMBER_TYPE,x); \
				return F; \
			} \
		} \
\
	case FLOAT_TYPE: \
\
		if(integerOnly) \
		{ \
			type_error(INTEGER_TYPE,x); \
			return F; \
		} \
\
		switch(type_of(y)) \
		{ \
		case FIXNUM_TYPE: \
			return OP##_float(x,(CELL)fixnum_to_float(y)); \
		case RATIO_TYPE: \
			return OP##_float(x,(CELL)ratio_to_float(y)); \
		case COMPLEX_TYPE: \
			return OP##_complex((CELL)complex(x,tag_fixnum(0)),y); \
		case BIGNUM_TYPE: \
			return OP##_float(x,(CELL)bignum_to_float(y)); \
		case FLOAT_TYPE: \
			return OP##_float(x,y); \
		default: \
			if(anytype) \
				return OP##_anytype(x,y); \
			else \
			{ \
				type_error(NUMBER_TYPE,x); \
				return F; \
			} \
		} \
\
	default: \
\
		if(anytype) \
			return OP##_anytype(x,y); \
		else \
		{ \
			type_error(NUMBER_TYPE,x); \
			return F; \
		} \
	} \
} \
\
void primitive_##OP(void) \
{ \
	CELL x = dpop(), y = env.dt; \
	env.dt = OP(x,y); \
}

#define UNARY_OP(OP,anytype,integerOnly) \
CELL OP(CELL x) \
{ \
	switch(type_of(x)) \
	{ \
	case FIXNUM_TYPE: \
		return OP##_fixnum(x); \
	case RATIO_TYPE: \
		if(integerOnly) \
		{ \
			type_error(INTEGER_TYPE,x); \
			return F; \
		} \
		else \
			return OP##_ratio(x); \
	case COMPLEX_TYPE: \
		if(integerOnly) \
		{ \
			type_error(INTEGER_TYPE,x); \
			return F; \
		} \
		else \
			return OP##_complex(x); \
	case BIGNUM_TYPE: \
		return OP##_bignum(x); \
	case FLOAT_TYPE: \
		if(integerOnly) \
		{ \
			type_error(INTEGER_TYPE,x); \
			return F; \
		} \
		else \
			return OP##_float(x); \
	default: \
		if(anytype) \
			return OP##_anytype(x); \
		else \
		{ \
			type_error(NUMBER_TYPE,x); \
			return F; \
		} \
	} \
} \
\
void primitive_##OP(void) \
{ \
	env.dt = OP(env.dt); \
}

bool realp(CELL tagged);
bool numberp(CELL tagged);
void primitive_numberp(void);

bool zerop(CELL tagged);

FIXNUM to_fixnum(CELL tagged);
void primitive_to_fixnum(void);
BIGNUM* to_bignum(CELL tagged);
void primitive_to_bignum(void);
CELL to_integer(CELL tagged);
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
CELL shiftleft(CELL x, CELL y);
void primitive_shiftleft(void);
CELL shiftright(CELL x, CELL y);
void primitive_shiftright(void);
CELL gcd(CELL x, CELL y);
void primitive_gcd(void);
