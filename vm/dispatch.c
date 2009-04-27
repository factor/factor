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
	return array_nth(hi_tag_methods,hi_tag(object) - HEADER_TYPE);
}

static CELL method_cache_hashcode(CELL key, F_ARRAY *array)
{
	CELL capacity = (array_capacity(array) >> 1) - 1;
	return ((key >> TAG_BITS) & capacity) << 1;
}

static CELL lookup_cached_method(CELL key, CELL method_cache)
{
	F_ARRAY *array = untag_object(method_cache);
	CELL hashcode = method_cache_hashcode(key,array);
	if(array_nth(array,hashcode) == key)
		return array_nth(array,hashcode + 1);
	else
		return F;
}

static void update_method_cache(CELL key, CELL method_cache, CELL method)
{
	F_ARRAY *array = untag_object(method_cache);
	CELL hashcode = method_cache_hashcode(key,array);
	set_array_nth(array,hashcode,key);
	set_array_nth(array,hashcode + 1,method);
}

static CELL lookup_method(CELL object, CELL methods, CELL method_cache)
{
	F_ARRAY *tag_methods = untag_object(methods);
	if(!HI_TAG_OR_TUPLE_P(object))
		return array_nth(tag_methods,TAG(object));
	else
	{
		CELL key = get(HI_TAG_HEADER(object));
		CELL method = lookup_cached_method(key,method_cache);
		if(method != F)
			return method;
		else
		{
			method = array_nth(tag_methods,TAG(object));
			if(type_of(method) != WORD_TYPE)
			{
				switch(TAG(object))
				{
				case TUPLE_TYPE:
					method = lookup_tuple_method(object,method);
					break;
				case OBJECT_TYPE:
					method = lookup_hi_tag_method(object,method);
					break;
				default:
					critical_error("Bad methods array",methods);
					break;
				}
			}

			update_method_cache(key,method_cache,method);
			return method;
		}
	}
}

void primitive_lookup_method(void)
{
	CELL method_cache = get(ds);
	CELL methods = get(ds - CELLS);
	CELL object = get(ds - CELLS * 2);
	ds -= CELLS * 2;
	drepl(lookup_method(object,methods,method_cache));
}
