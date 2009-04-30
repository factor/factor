#include "master.h"

static CELL search_lookup_alist(CELL table, CELL class)
{
	F_ARRAY *pairs = untag_object(table);
	F_FIXNUM index = array_capacity(pairs) - 1;
	while(index >= 0)
	{
		F_ARRAY *pair = untag_object(array_nth(pairs,index));
		if(array_nth(pair,0) == class)
			return array_nth(pair,1);
		else
			index--;
	}

	return F;
}

static CELL search_lookup_hash(CELL table, CELL class, CELL hashcode)
{
	F_ARRAY *buckets = untag_object(table);
	CELL bucket = array_nth(buckets,hashcode & (array_capacity(buckets) - 1));
	if(type_of(bucket) == WORD_TYPE || bucket == F)
		return bucket;
	else
		return search_lookup_alist(bucket,class);
}

static CELL nth_superclass(F_TUPLE_LAYOUT *layout, F_FIXNUM echelon)
{
	CELL *ptr = (CELL *)(layout + 1);
	return ptr[echelon * 2];
}

static CELL nth_hashcode(F_TUPLE_LAYOUT *layout, F_FIXNUM echelon)
{
	CELL *ptr = (CELL *)(layout + 1);
	return ptr[echelon * 2 + 1];
}

static CELL lookup_tuple_method(CELL object, CELL methods)
{
	F_TUPLE *tuple = untag_object(object);
	F_TUPLE_LAYOUT *layout = untag_object(tuple->layout);

	F_ARRAY *echelons = untag_object(methods);

	F_FIXNUM echelon = untag_fixnum_fast(layout->echelon);
	F_FIXNUM max_echelon = array_capacity(echelons) - 1;
	if(echelon > max_echelon) echelon = max_echelon;
       
	while(echelon >= 0)
	{
		CELL echelon_methods = array_nth(echelons,echelon);

		if(type_of(echelon_methods) == WORD_TYPE)
			return echelon_methods;
		else if(echelon_methods != F)
		{
			CELL class = nth_superclass(layout,echelon);
			CELL hashcode = untag_fixnum_fast(nth_hashcode(layout,echelon));
			CELL result = search_lookup_hash(echelon_methods,class,hashcode);
			if(result != F)
				return result;
		}

		echelon--;
	}

	critical_error("Cannot find tuple method",methods);
	return F;
}

static CELL lookup_hi_tag_method(CELL object, CELL methods)
{
	F_ARRAY *hi_tag_methods = untag_object(methods);
	CELL tag = hi_tag(object) - HEADER_TYPE;
#ifdef FACTOR_DEBUG
	assert(tag < TYPE_COUNT - HEADER_TYPE);
#endif
	return array_nth(hi_tag_methods,tag);
}

static CELL lookup_hairy_method(CELL object, CELL methods)
{
	CELL method = array_nth(untag_object(methods),TAG(object));
	if(type_of(method) == WORD_TYPE)
		return method;
	else
	{
		switch(TAG(object))
		{
		case TUPLE_TYPE:
			return lookup_tuple_method(object,method);
			break;
		case OBJECT_TYPE:
			return lookup_hi_tag_method(object,method);
			break;
		default:
			critical_error("Bad methods array",methods);
			return -1;
		}
	}
}

CELL lookup_method(CELL object, CELL methods)
{
	if(!HI_TAG_OR_TUPLE_P(object))
		return array_nth(untag_object(methods),TAG(object));
	else
		return lookup_hairy_method(object,methods);
}

void primitive_lookup_method(void)
{
	CELL methods = dpop();
	CELL object = dpop();
	dpush(lookup_method(object,methods));
}

CELL object_class(CELL object)
{
	if(!HI_TAG_OR_TUPLE_P(object))
		return tag_fixnum(TAG(object));
	else
		return get(HI_TAG_HEADER(object));
}

static CELL method_cache_hashcode(CELL class, F_ARRAY *array)
{
	CELL capacity = (array_capacity(array) >> 1) - 1;
	return ((class >> TAG_BITS) & capacity) << 1;
}

static void update_method_cache(CELL cache, CELL class, CELL method)
{
	F_ARRAY *array = untag_object(cache);
	CELL hashcode = method_cache_hashcode(class,array);
	set_array_nth(array,hashcode,class);
	set_array_nth(array,hashcode + 1,method);
}

void primitive_mega_cache_miss(void)
{
	megamorphic_cache_misses++;

	CELL cache = dpop();
	F_FIXNUM index = untag_fixnum_fast(dpop());
	CELL methods = dpop();

	CELL object = get(ds - index * CELLS);
	CELL class = object_class(object);
	CELL method = lookup_method(object,methods);

	update_method_cache(cache,class,method);

	dpush(method);
}

void primitive_reset_dispatch_stats(void)
{
	megamorphic_cache_hits = megamorphic_cache_misses = 0;
}

void primitive_dispatch_stats(void)
{
	GROWABLE_ARRAY(stats);
	GROWABLE_ARRAY_ADD(stats,allot_cell(megamorphic_cache_hits));
	GROWABLE_ARRAY_ADD(stats,allot_cell(megamorphic_cache_misses));
	GROWABLE_ARRAY_TRIM(stats);
	GROWABLE_ARRAY_DONE(stats);
	dpush(stats);
}

void jit_emit_class_lookup(F_JIT *jit, F_FIXNUM index, CELL type)
{
	jit_emit_with(jit,userenv[PIC_LOAD],tag_fixnum(-index * CELLS));
	jit_emit(jit,userenv[type]);
}

void jit_emit_mega_cache_lookup(F_JIT *jit, CELL methods, F_FIXNUM index, CELL cache)
{
	/* Generate machine code to determine the object's class. */
	jit_emit_class_lookup(jit,index,PIC_HI_TAG_TUPLE);

	/* Do a cache lookup. */
	jit_emit_with(jit,userenv[MEGA_LOOKUP],cache);
	
	/* If we end up here, the cache missed. */
	jit_emit(jit,userenv[JIT_PROLOG]);

	/* Push index, method table and cache on the stack. */
	jit_push(jit,methods);
	jit_push(jit,tag_fixnum(index));
	jit_push(jit,cache);
	jit_word_call(jit,userenv[MEGA_MISS_WORD]);

	/* Now the new method has been stored into the cache, and its on
	   the stack. */
	jit_emit(jit,userenv[JIT_EPILOG]);
	jit_emit(jit,userenv[JIT_EXECUTE_JUMP]);
}
