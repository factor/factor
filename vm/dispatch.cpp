#include "master.hpp"

namespace factor
{

cell factor_vm::search_lookup_alist(cell table, cell klass)
{
	array *elements = untag<array>(table);
	fixnum index = array_capacity(elements) - 2;
	while(index >= 0)
	{
		if(array_nth(elements,index) == klass)
			return array_nth(elements,index + 1);
		else
			index -= 2;
	}

	return F;
}

cell factor_vm::search_lookup_hash(cell table, cell klass, cell hashcode)
{
	array *buckets = untag<array>(table);
	cell bucket = array_nth(buckets,hashcode & (array_capacity(buckets) - 1));
	if(tagged<object>(bucket).type_p(WORD_TYPE) || bucket == F)
		return bucket;
	else
		return search_lookup_alist(bucket,klass);
}

cell factor_vm::nth_superclass(tuple_layout *layout, fixnum echelon)
{
	cell *ptr = (cell *)(layout + 1);
	return ptr[echelon * 2];
}

cell factor_vm::nth_hashcode(tuple_layout *layout, fixnum echelon)
{
	cell *ptr = (cell *)(layout + 1);
	return ptr[echelon * 2 + 1];
}

cell factor_vm::lookup_tuple_method(cell obj, cell methods)
{
	tuple_layout *layout = untag<tuple_layout>(untag<tuple>(obj)->layout);

	array *echelons = untag<array>(methods);

	fixnum echelon = untag_fixnum(layout->echelon);
	fixnum max_echelon = array_capacity(echelons) - 1;
	if(echelon > max_echelon) echelon = max_echelon;
       
	while(echelon >= 0)
	{
		cell echelon_methods = array_nth(echelons,echelon);

		if(tagged<object>(echelon_methods).type_p(WORD_TYPE))
			return echelon_methods;
		else if(echelon_methods != F)
		{
			cell klass = nth_superclass(layout,echelon);
			cell hashcode = untag_fixnum(nth_hashcode(layout,echelon));
			cell result = search_lookup_hash(echelon_methods,klass,hashcode);
			if(result != F)
				return result;
		}

		echelon--;
	}

	critical_error("Cannot find tuple method",methods);
	return F;
}

cell factor_vm::lookup_hi_tag_method(cell obj, cell methods)
{
	array *hi_tag_methods = untag<array>(methods);
	cell tag = untag<object>(obj)->h.hi_tag() - HEADER_TYPE;
#ifdef FACTOR_DEBUG
	assert(tag < TYPE_COUNT - HEADER_TYPE);
#endif
	return array_nth(hi_tag_methods,tag);
}

cell factor_vm::lookup_hairy_method(cell obj, cell methods)
{
	cell method = array_nth(untag<array>(methods),TAG(obj));
	if(tagged<object>(method).type_p(WORD_TYPE))
		return method;
	else
	{
		switch(TAG(obj))
		{
		case TUPLE_TYPE:
			return lookup_tuple_method(obj,method);
			break;
		case OBJECT_TYPE:
			return lookup_hi_tag_method(obj,method);
			break;
		default:
			critical_error("Bad methods array",methods);
			return 0;
		}
	}
}

cell factor_vm::lookup_method(cell obj, cell methods)
{
	cell tag = TAG(obj);
	if(tag == TUPLE_TYPE || tag == OBJECT_TYPE)
		return lookup_hairy_method(obj,methods);
	else
		return array_nth(untag<array>(methods),TAG(obj));
}

void factor_vm::primitive_lookup_method()
{
	cell methods = dpop();
	cell obj = dpop();
	dpush(lookup_method(obj,methods));
}

cell factor_vm::object_class(cell obj)
{
	switch(TAG(obj))
	{
	case TUPLE_TYPE:
		return untag<tuple>(obj)->layout;
	case OBJECT_TYPE:
		return untag<object>(obj)->h.value;
	default:
		return tag_fixnum(TAG(obj));
	}
}

cell factor_vm::method_cache_hashcode(cell klass, array *array)
{
	cell capacity = (array_capacity(array) >> 1) - 1;
	return ((klass >> TAG_BITS) & capacity) << 1;
}

void factor_vm::update_method_cache(cell cache, cell klass, cell method)
{
	array *cache_elements = untag<array>(cache);
	cell hashcode = method_cache_hashcode(klass,cache_elements);
	set_array_nth(cache_elements,hashcode,klass);
	set_array_nth(cache_elements,hashcode + 1,method);
}

void factor_vm::primitive_mega_cache_miss()
{
	megamorphic_cache_misses++;

	cell cache = dpop();
	fixnum index = untag_fixnum(dpop());
	cell methods = dpop();

	cell object = ((cell *)ds)[-index];
	cell klass = object_class(object);
	cell method = lookup_method(object,methods);

	update_method_cache(cache,klass,method);

	dpush(method);
}

void factor_vm::primitive_reset_dispatch_stats()
{
	megamorphic_cache_hits = megamorphic_cache_misses = 0;
}

void factor_vm::primitive_dispatch_stats()
{
	growable_array stats(this);
	stats.add(allot_cell(megamorphic_cache_hits));
	stats.add(allot_cell(megamorphic_cache_misses));
	stats.trim();
	dpush(stats.elements.value());
}

void quotation_jit::emit_mega_cache_lookup(cell methods_, fixnum index, cell cache_)
{
	gc_root<array> methods(methods_,parent_vm);
	gc_root<array> cache(cache_,parent_vm);

	/* Generate machine code to determine the object's class. */
	emit_class_lookup(index,PIC_HI_TAG_TUPLE);

	/* Do a cache lookup. */
	emit_with(parent_vm->userenv[MEGA_LOOKUP],cache.value());
	
	/* If we end up here, the cache missed. */
	emit(parent_vm->userenv[JIT_PROLOG]);

	/* Push index, method table and cache on the stack. */
	push(methods.value());
	push(tag_fixnum(index));
	push(cache.value());
	word_call(parent_vm->userenv[MEGA_MISS_WORD]);

	/* Now the new method has been stored into the cache, and its on
	   the stack. */
	emit(parent_vm->userenv[JIT_EPILOG]);
	emit(parent_vm->userenv[JIT_EXECUTE_JUMP]);
}

}
