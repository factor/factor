#include "factor.h"

bool typep(CELL type, CELL tagged)
{
	if(type < HEADER_TYPE)
	{
		if(TAG(tagged) == type)
			return true;
	}
	else if(type >= HEADER_TYPE)
	{
		if(TAG(tagged) == OBJECT_TYPE)
		{
			if(untag_header(get(UNTAG(tagged))) == type)
				return true;
		}
	}
	
	return false;
}

CELL type_of(CELL tagged)
{
	CELL tag = TAG(tagged);
	if(tag != OBJECT_TYPE)
		return tag;
	else
		return untag_header(get(UNTAG(tagged)));
}

void type_check(CELL type, CELL tagged)
{
	if(type < HEADER_TYPE)
	{
		if(TAG(tagged) == type)
			return;
	}
	else if(type >= HEADER_TYPE)
	{
		if(TAG(tagged) == OBJECT_TYPE)
		{
			if(untag_header(get(UNTAG(tagged))) == type)
				return;
		}
	}
	
	type_error(type,tagged);
}

/*
 * It is up to the caller to fill in the object's fields in a meaningful
 * fashion!
 */
CELL allot_object(CELL type, CELL length)
{
	CELL object = allot(length);
	put(object,tag_header(type));
	return object;
}

CELL object_size(CELL pointer)
{
	switch(TAG(pointer))
	{
	case CONS_TYPE:
		return align8(sizeof(CONS));
	case WORD_TYPE:
		return align8(sizeof(WORD));
	case OBJECT_TYPE:
		return untagged_object_size(UNTAG(pointer));
	default:
		critical_error("Cannot determine size",pointer);
		return -1;
	}
}

CELL untagged_object_size(CELL pointer)
{
	CELL size;
	
	switch(untag_header(get(pointer)))
	{
	case F_TYPE:
	case T_TYPE:
	case EMPTY_TYPE:
		size = CELLS * 2;
		break;
	case ARRAY_TYPE:
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
	case HANDLE_TYPE:
		size = sizeof(HANDLE);
		break;
	default:
		critical_error("Cannot determine size",relocating);
		size = -1;/* can't happen */
		break;
	}

	return align8(size);
}
