#include "factor.h"

BIGNUM* fixnum_to_bignum(CELL n);
RATIO* fixnum_to_ratio(CELL n);
FIXNUM bignum_to_fixnum(CELL tagged);
RATIO* bignum_to_ratio(CELL n);

#define CELL_TO_INTEGER(result) \
	FIXNUM _result = (result); \
	if(_result < FIXNUM_MIN || _result > FIXNUM_MAX) \
		return tag_bignum(fixnum_to_bignum(_result)); \
	else \
		return tag_fixnum(_result);

#define BIGNUM_2_TO_INTEGER(result) \
        BIGNUM_2 _result = (result); \
        if(_result < FIXNUM_MIN || _result > FIXNUM_MAX) \
                return tag_bignum(bignum(_result)); \
        else \
                return tag_fixnum(_result);

#define BINARY_OP(OP,anytype,integerOnly) \
CELL OP(CELL x, CELL y) \
{ \
	switch(TAG(x)) \
	{ \
	case FIXNUM_TYPE: \
\
		switch(TAG(y)) \
		{ \
		case FIXNUM_TYPE: \
			return OP##_fixnum(x,y); \
		case OBJECT_TYPE: \
			switch(object_type(y)) \
			{ \
			case BIGNUM_TYPE: \
				return OP##_bignum((CELL)fixnum_to_bignum(x),y); \
			default: \
				if(anytype) \
					return OP##_anytype(x,y); \
				else \
					type_error(FIXNUM_TYPE,y); \
				return F; \
			} \
			break; \
		case RATIO_TYPE: \
			if(integerOnly) \
				return OP(x,to_integer(y)); \
			else \
				return OP##_ratio((CELL)fixnum_to_ratio(x),y); \
		default: \
			if(anytype) \
				return OP##_anytype(x,y); \
			else \
				type_error(FIXNUM_TYPE,y); \
			return F; \
		} \
\
	case OBJECT_TYPE: \
\
		switch(object_type(x)) \
		{ \
	 \
		case BIGNUM_TYPE: \
		 \
			switch(TAG(y)) \
			{ \
			case FIXNUM_TYPE: \
				return OP##_bignum(x,(CELL)fixnum_to_bignum(y)); \
			case OBJECT_TYPE: \
\
				switch(object_type(y)) \
				{ \
				case BIGNUM_TYPE: \
					return OP##_bignum(x,y); \
				default: \
					type_error(BIGNUM_TYPE,y); \
					return F; \
				} \
			case RATIO_TYPE: \
				if(integerOnly) \
					return OP(x,to_integer(y)); \
				else \
					return OP##_ratio((CELL)bignum_to_ratio(x),y); \
			default: \
				if(anytype) \
					return OP##_anytype(x,y); \
				else \
					type_error(BIGNUM_TYPE,y); \
				return F; \
			} \
\
		default: \
\
			if(anytype) \
				return OP##_anytype(x,y); \
			else \
				type_error(FIXNUM_TYPE,x); \
			return F; \
		} \
\
	case RATIO_TYPE: \
\
		switch(TAG(y)) \
		{ \
		case FIXNUM_TYPE: \
			if(integerOnly) \
				return OP(to_integer(x),y); \
			else \
				return OP##_ratio(x,(CELL)fixnum_to_ratio(y)); \
		case OBJECT_TYPE: \
			switch(object_type(y)) \
			{ \
			case BIGNUM_TYPE: \
				if(integerOnly) \
					return OP(to_integer(x),y); \
				else \
					return OP##_ratio(x,(CELL)bignum_to_ratio(y)); \
			default: \
				if(anytype) \
					return OP##_anytype(x,y); \
				else \
					type_error(FIXNUM_TYPE,y); \
				return F; \
			} \
			break; \
		case RATIO_TYPE: \
			if(integerOnly) \
				return OP(to_integer(x),to_integer(y)); \
			else \
				return OP##_ratio(x,y); \
		default: \
			if(anytype) \
				return OP##_anytype(x,y); \
			else \
				type_error(FIXNUM_TYPE,y); \
			return F; \
		} \
\
	default: \
\
		if(anytype) \
			return OP##_anytype(x,y); \
		else \
			type_error(FIXNUM_TYPE,x); \
		return F; \
	} \
} \
\
void primitive_##OP(void) \
{ \
	CELL x = dpop(), y = env.dt; \
	env.dt = OP(x,y); \
}

void primitive_numberp(void);

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
void primitive_divide(void);
void primitive_less(void);
void primitive_lesseq(void);
void primitive_greater(void);
void primitive_greatereq(void);
void primitive_mod(void);
void primitive_and(void);
void primitive_or(void);
void primitive_xor(void);
void primitive_shiftleft(void);
void primitive_shiftright(void);
