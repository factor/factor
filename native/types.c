#include "factor.h"

CELL type_of(CELL tagged)
{
	CELL tag = TAG(tagged);
	if(tag == OBJECT_TYPE)
	{
		if(tagged == F)
			return F_TYPE;
		else
			return untag_header(get(UNTAG(tagged)));
	}
	else
		return tag;
}

bool typep(CELL type, CELL tagged)
{
	return type_of(tagged) == type;
}

void type_check(CELL type, CELL tagged)
{
	if(type_of(tagged) != type)
		type_error(type,tagged);
}

/*
 * It is up to the caller to fill in the object's fields in a meaningful
 * fashion!
 */
void* allot_object(CELL type, CELL length)
{
	CELL* object = allot(length);
	*object = tag_header(type);
	return object;
}

CELL object_size(CELL pointer)
{
	CELL size;

	switch(TAG(pointer))
	{
	case FIXNUM_TYPE:
		size = 0;
		break;
	case CONS_TYPE:
		size = sizeof(CONS);
		break;
	case WORD_TYPE:
		size = sizeof(WORD);
		break;
	case RATIO_TYPE:
		size = sizeof(RATIO);
		break;
	case COMPLEX_TYPE:
		size = sizeof(COMPLEX);
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
		size = sizeof(WORD);
		break;
	case T_TYPE:
		size = CELLS * 2;
		break;
	case ARRAY_TYPE:
	case BIGNUM_TYPE:
		size = ASIZE(pointer);
		break;
	case VECTOR_TYPE:
		size = sizeof(VECTOR);
		break;
	case STRING_TYPE:
		size = SSIZE(pointer);
		break;
	case SBUF_TYPE:
		size = sizeof(SBUF);
		break;
	case FLOAT_TYPE:
		size = sizeof(FLOAT);
		break;
	case PORT_TYPE:
		size = sizeof(PORT);
		break;
	default:
		critical_error("Cannot determine size",relocating);
		size = -1;/* can't happen */
		break;
	}

	return align8(size);
}

void primitive_type_of(void)
{
	drepl(tag_fixnum(type_of(dpeek())));
}

void primitive_size_of(void)
{
	drepl(tag_fixnum(object_size(dpeek())));
}
