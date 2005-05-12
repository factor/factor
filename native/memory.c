#include "factor.h"

CELL init_zone(ZONE *z, CELL size, CELL base)
{
	z->base = z->here = base;
	z->limit = z->base + size;
	z->alarm = z->base + (size * 3) / 4;
	return z->limit;
}

/* input parameters must be 8 byte aligned */
/* the heap layout is important:
- two semispaces: tenured and prior
- younger generations follow */
void init_arena(CELL young_size, CELL aging_size)
{
	int i;
	CELL alloter;

	CELL total_size = (GC_GENERATIONS - 1) * young_size + 2 * aging_size;
	CELL cards_size = total_size / CARD_SIZE;

	heap_start = (CELL)alloc_guarded(total_size);
	heap_end = heap_start + total_size;

	cards = alloc_guarded(cards_size);
	cards_end = cards + cards_size;

	alloter = heap_start;

	if(heap_start == 0)
		fatal_error("Cannot allocate data heap",total_size);

	alloter = init_zone(&tenured,aging_size,alloter);
	alloter = init_zone(&prior,aging_size,alloter);

	for(i = GC_GENERATIONS - 2; i >= 0; i--)
		alloter = init_zone(&generations[i],young_size,alloter);

	clear_cards(TENURED,NURSERY);

	allot_zone = &nursery;

	if(alloter != heap_start + total_size)
		fatal_error("Oops",alloter);

	allot_profiling = false;
	gc_in_progress = false;
	heap_scan = false;
	gc_time = 0;
}

void allot_profile_step(CELL a)
{
	CELL depth = (cs - cs_bot) / CELLS;
	int i;
	CELL obj;

	if(gc_in_progress)
		return;

	for(i = profile_depth; i < depth; i++)
	{
		obj = get(cs_bot + i * CELLS);
		if(type_of(obj) == WORD_TYPE)
			untag_word(obj)->allot_count += a;
	}

	if(in_zone(&prior,executing))
		critical_error("executing in prior zone",executing);
	untag_word_fast(executing)->allot_count += a;
}

void primitive_room(void)
{
	CELL list = F;
	int gen;
	box_signed_cell(compiling.limit - compiling.here);
	box_signed_cell(compiling.limit - compiling.base);
	box_signed_cell(cards_end - cards);
	box_signed_cell(prior.limit - prior.base);
	for(gen = GC_GENERATIONS - 1; gen >= 0; gen--)
	{
		ZONE *z = &generations[gen];
		list = cons(cons(
			tag_fixnum(z->limit - z->here),
			tag_fixnum(z->limit - z->base)),
			list);
	}
	dpush(list);
}

void primitive_allot_profiling(void)
{
	CELL d = dpop();
	if(d == F)
		allot_profiling = false;
	else
	{
		allot_profiling = true;
		profile_depth = to_fixnum(d);
	}
}

void primitive_address(void)
{
	drepl(tag_bignum(s48_ulong_to_bignum(dpeek())));
}

void primitive_size(void)
{
	drepl(tag_fixnum(object_size(dpeek())));
}

void primitive_begin_scan(void)
{
	garbage_collection(TENURED);
	heap_scan_ptr = tenured.base;
	heap_scan_end = tenured.here;
	heap_scan = true;
}

void primitive_next_object(void)
{
	CELL value = get(heap_scan_ptr);
	CELL obj = heap_scan_ptr;
	CELL size, type;

	if(!heap_scan)
		general_error(ERROR_HEAP_SCAN,F);

	if(heap_scan_ptr >= heap_scan_end)
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
