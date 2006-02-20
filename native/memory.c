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
		size = untagged_object_size(UNTAG(pointer));
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
		size = sizeof(F_CONS);
		break;
	case OBJECT_TYPE:
		if(pointer == F)
			size = 0;
		else
			size = untagged_object_size(UNTAG(pointer));
		break;
	default:
		critical_error("Cannot determine object_size",pointer);
		size = 0; /* Can't happen */
		break;
	}

	return align8(size);
}

CELL untagged_object_size(CELL pointer)
{
	CELL size;

	switch(untag_header(get(pointer)))
	{
	case WORD_TYPE:
		size = sizeof(F_WORD);
		break;
	case ARRAY_TYPE:
	case TUPLE_TYPE:
	case BIGNUM_TYPE:
	case BYTE_ARRAY_TYPE:
		size = array_size(array_capacity((F_ARRAY*)(pointer)));
		break;
	case HASHTABLE_TYPE:
		size = sizeof(F_HASHTABLE);
		break;
	case VECTOR_TYPE:
		size = sizeof(F_VECTOR);
		break;
	case STRING_TYPE:
		size = string_size(string_capacity((F_STRING*)(pointer)));
		break;
	case SBUF_TYPE:
		size = sizeof(F_SBUF);
		break;
	case FLOAT_TYPE:
		size = sizeof(F_FLOAT);
		break;
	case DLL_TYPE:
		size = sizeof(DLL);
		break;
	case ALIEN_TYPE:
		size = sizeof(ALIEN);
		break;
	case WRAPPER_TYPE:
		size = sizeof(F_WRAPPER);
		break;
	default:
		critical_error("Cannot determine untagged_object_size",pointer);
		size = -1;/* can't happen */
		break;
	}

	return align8(size);
}

void primitive_type(void)
{
	drepl(tag_fixnum(type_of(dpeek())));
}

void primitive_tag(void)
{
	drepl(tag_fixnum(TAG(dpeek())));
}

void primitive_slot(void)
{
	F_FIXNUM slot = untag_fixnum_fast(dpop());
	CELL obj = UNTAG(dpop());
	dpush(get(SLOT(obj,slot)));
}

void primitive_set_slot(void)
{
	F_FIXNUM slot = untag_fixnum_fast(dpop());
	CELL obj = UNTAG(dpop());
	CELL value = dpop();
	put(SLOT(obj,slot),value);
	write_barrier(obj);
}

void primitive_integer_slot(void)
{
	F_FIXNUM slot = untag_fixnum_fast(dpop());
	CELL obj = UNTAG(dpop());
	dpush(tag_integer(get(SLOT(obj,slot))));
}

void primitive_set_integer_slot(void)
{
	F_FIXNUM slot = untag_fixnum_fast(dpop());
	CELL obj = UNTAG(dpop());
	F_FIXNUM value = to_fixnum(dpop());
	put(SLOT(obj,slot),value);
}

void primitive_address(void)
{
	drepl(tag_bignum(s48_cell_to_bignum(dpeek())));
}

void primitive_size(void)
{
	drepl(tag_fixnum(object_size(dpeek())));
}

CELL clone(CELL obj)
{
	CELL size = object_size(obj);
	CELL tag = TAG(obj);
	void *new_obj = allot(size);
	return RETAG(memcpy(new_obj,(void*)UNTAG(obj),size),tag);
}

void primitive_clone(void)
{
	maybe_gc(0);
	drepl(clone(dpeek()));
}

void primitive_room(void)
{
	CELL list = F;
	int gen;
	box_unsigned_cell(compiling.limit - compiling.here);
	box_unsigned_cell(compiling.limit - compiling.base);
	box_unsigned_cell(cards_end - cards);
	box_unsigned_cell(prior.limit - prior.base);
	for(gen = gen_count - 1; gen >= 0; gen--)
	{
		ZONE *z = &generations[gen];
		list = cons(cons(tag_cell(z->limit - z->here),
			tag_cell(z->limit - z->base)),
			list);
	}
	dpush(list);
}

void primitive_begin_scan(void)
{
	garbage_collection(TENURED);
	heap_scan_ptr = tenured.base;
	heap_scan = true;
}

void primitive_next_object(void)
{
	CELL value = get(heap_scan_ptr);
	CELL obj = heap_scan_ptr;
	CELL size, type;

	if(!heap_scan)
		general_error(ERROR_HEAP_SCAN,F,true);

	if(heap_scan_ptr >= tenured.here)
	{
		dpush(F);
		return;
	}
	
	if(headerp(value))
	{
		size = align8(untagged_object_size(heap_scan_ptr));
		type = untag_header(value);
	}
	else
	{
		size = CELLS * 2;
		type = CONS_TYPE;
	}

	heap_scan_ptr += size;

	if(type < HEADER_TYPE)
		dpush(RETAG(obj,type));
	else
		dpush(RETAG(obj,OBJECT_TYPE));
}

void primitive_end_scan(void)
{
	heap_scan = false;
}
