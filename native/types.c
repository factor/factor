#include "factor.h"

CELL object_size(CELL pointer)
{
	CELL size;

	switch(TAG(pointer))
	{
	case FIXNUM_TYPE:
		size = 0;
		break;
	case BIGNUM_TYPE:
		size = ASIZE(UNTAG(pointer));
		break;
	case CONS_TYPE:
		size = sizeof(F_CONS);
		break;
	case RATIO_TYPE:
		size = sizeof(F_RATIO);
		break;
	case FLOAT_TYPE:
		size = sizeof(F_FLOAT);
		break;
	case COMPLEX_TYPE:
		size = sizeof(F_COMPLEX);
		break;
	case OBJECT_TYPE:
		size = untagged_object_size(UNTAG(pointer));
		break;
	default:
		critical_error("Cannot determine size",pointer);
		size = 0; /* Can't happen */
		break;
	}

	return align8(size);
}

CELL untagged_object_size(CELL pointer)
{
	CELL size;

	if(pointer == F)
		return 0;

	switch(untag_header(get(pointer)))
	{
	case WORD_TYPE:
		size = sizeof(F_WORD);
		break;
	case T_TYPE:
		size = CELLS * 2;
		break;
	case ARRAY_TYPE:
	case BIGNUM_TYPE:
		size = ASIZE(pointer);
		break;
	case HASHTABLE_TYPE:
		size = sizeof(F_HASHTABLE);
		break;
	case VECTOR_TYPE:
		size = sizeof(F_VECTOR);
		break;
	case STRING_TYPE:
		size = SSIZE(pointer);
		break;
	case SBUF_TYPE:
		size = sizeof(F_SBUF);
		break;
	case FLOAT_TYPE:
		size = sizeof(F_FLOAT);
		break;
	case PORT_TYPE:
		size = sizeof(F_PORT);
		break;
	case DLL_TYPE:
		size = sizeof(DLL);
		break;
	case ALIEN_TYPE:
		size = sizeof(ALIEN);
		break;
	default:
		critical_error("Cannot determine size",pointer);
		size = -1;/* can't happen */
		break;
	}

	return align8(size);
}

void primitive_type(void)
{
	drepl(tag_fixnum(type_of(dpeek())));
}

#define SLOT(obj,slot) UNTAG(obj) + slot * CELLS

void primitive_slot(void)
{
	F_FIXNUM slot = untag_fixnum_fast(dpop());
	CELL obj = dpop();
	dpush(get(SLOT(obj,slot)));
}

void primitive_set_slot(void)
{
	F_FIXNUM slot = untag_fixnum_fast(dpop());
	CELL obj = dpop();
	CELL value = dpop();
	put(SLOT(obj,slot),value);
}

void primitive_integer_slot(void)
{
	F_FIXNUM slot = untag_fixnum_fast(dpop());
	CELL obj = dpop();
	dpush(tag_integer(get(SLOT(obj,slot))));
}

void primitive_set_integer_slot(void)
{
	F_FIXNUM slot = untag_fixnum_fast(dpop());
	CELL obj = dpop();
	F_FIXNUM value = to_fixnum(dpop());
	put(SLOT(obj,slot),value);
}
