#include "factor.h"

INLINE BIGNUM* fixnum_to_bignum(CELL n)
{
	return bignum((BIGNUM_2)untag_fixnum_fast(n));
}

INLINE FIXNUM bignum_to_fixnum(CELL tagged)
{
	return (FIXNUM)(untag_bignum(tagged)->n);
}

#define BINARY_OP(OP) \
void primitive_##OP(void) \
{ \
	CELL x = dpop(), y = env.dt; \
\
	switch(TAG(x)) \
	{ \
	case FIXNUM_TYPE: \
\
		switch(TAG(y)) \
		{ \
		case FIXNUM_TYPE: \
			OP##_fixnum(x,y); \
			break; \
		case OBJECT_TYPE: \
			switch(object_type(y)) \
			{ \
			case BIGNUM_TYPE: \
				OP##_bignum(fixnum_to_bignum(x),y); \
				break; \
			default: \
				type_error(FIXNUM_TYPE,y); \
				break; \
			} \
			break; \
		default: \
			type_error(FIXNUM_TYPE,y); \
			break; \
		} \
\
		break; \
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
				OP##_bignum(x,fixnum_to_bignum(y)); \
				break; \
			case OBJECT_TYPE: \
\
				switch(object_type(y)) \
				{ \
				case BIGNUM_TYPE: \
					OP##_bignum(x,y); \
					break; \
				default: \
					type_error(BIGNUM_TYPE,y); \
					break; \
				} \
				break; \
			default: \
				type_error(BIGNUM_TYPE,y); \
				break; \
			} \
			break; \
\
		default: \
\
			type_error(FIXNUM_TYPE,x); \
			break; \
		} \
\
		break; \
\
	default: \
\
		type_error(FIXNUM_TYPE,x); \
		break; \
	} \
}

void primitive_add(void);
void primitive_subtract(void);
void primitive_multiply(void);
void primitive_divmod(void);
void primitive_less(void);
void primitive_lesseq(void);
void primitive_greater(void);
void primitive_greatereq(void);
