#include "factor.h"

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
			env.dt = OP##_fixnum(x,y); \
			break; \
		case OBJECT_TYPE: \
			switch(object_type(y)) \
			{ \
			case BIGNUM_TYPE: \
				env.dt = OP##_bignum(fixnum_to_bignum(x),y); \
				break; \
			default: \
				type_error(y,FIXNUM_TYPE); \
				break; \
			} \
			break; \
		default: \
			type_error(y,FIXNUM_TYPE); \
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
				env.dt = OP##_bignum(x,fixnum_to_bignum(y)); \
				break; \
			case OBJECT_TYPE: \
\
				switch(object_type(y)) \
				{ \
				case BIGNUM_TYPE: \
					env.dt = OP##_bignum(x,y); \
					break; \
				default: \
					type_error(y,BIGNUM_TYPE); \
					break; \
				} \
				break; \
			default: \
				type_error(y,BIGNUM_TYPE); \
				break; \
			} \
			break; \
\
		default: \
\
			type_error(x,FIXNUM_TYPE); \
			break; \
		} \
\
	default: \
\
		type_error(x,FIXNUM_TYPE); \
	} \
}

/* ADDITION */
INLINE CELL add_fixnum(CELL x, CELL y)
{
	CELL result = untag_fixnum_fast(x) + untag_fixnum_fast(y);
	if(result & ~FIXNUM_MASK)
		return tag_bignum(fixnum_to_bignum(result));
	else
		return tag_fixnum(result);
}

INLINE CELL add_bignum(CELL x, CELL y)
{
	return tag_object(bignum(((BIGNUM*)UNTAG(x))->n
		+ ((BIGNUM*)UNTAG(y))->n));
}

BINARY_OP(add)
