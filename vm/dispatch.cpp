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

	return false_object;
}

cell factor_vm::search_lookup_hash(cell table, cell klass, cell hashcode)
{
	array *buckets = untag<array>(table);
	cell bucket = array_nth(buckets,hashcode & (array_capacity(buckets) - 1));
	if(TAG(bucket) == ARRAY_TYPE)
		return search_lookup_alist(bucket,klass);
	else
		return bucket;
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

	fixnum echelon = std::min(untag_fixnum(layout->echelon),(fixnum)array_capacity(echelons) - 1);

	while(echelon >= 0)
	{
		cell echelon_methods = array_nth(echelons,echelon);

		if(tagged<object>(echelon_methods).type_p(WORD_TYPE))
			return echelon_methods;
		else if(to_boolean(echelon_methods))
		{
			cell klass = nth_superclass(layout,echelon);
			cell hashcode = untag_fixnum(nth_hashcode(layout,echelon));
			cell result = search_lookup_hash(echelon_methods,klass,hashcode);
			if(to_boolean(result))
				return result;
		}

		echelon--;
	}

	critical_error("Cannot find tuple method",methods);
	return false_object;
}

cell factor_vm::lookup_method(cell obj, cell methods)
{
	cell tag = TAG(obj);
	cell method = array_nth(untag<array>(methods),tag);

	if(tag == TUPLE_TYPE)
	{
		if(TAG(method) == ARRAY_TYPE)
			return lookup_tuple_method(obj,method);
		else
			return method;
	}
	else
		return method;
}

void factor_vm::primitive_lookup_method()
{
	cell methods = ctx->pop();
	cell obj = ctx->pop();
	ctx->push(lookup_method(obj,methods));
}

cell factor_vm::object_class(cell obj)
{
	cell tag = TAG(obj);
	if(tag == TUPLE_TYPE)
		return untag<tuple>(obj)->layout;
	else
		return tag_fixnum(tag);
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
	dispatch_stats.megamorphic_cache_misses++;

	cell cache = ctx->pop();
	fixnum index = untag_fixnum(ctx->pop());
	cell methods = ctx->pop();

	cell object = ((cell *)ctx->datastack)[-index];
	cell klass = object_class(object);
	cell method = lookup_method(object,methods);

	update_method_cache(cache,klass,method);

	ctx->push(method);
}

void factor_vm::primitive_reset_dispatch_stats()
{
	memset(&dispatch_stats,0,sizeof(dispatch_statistics));
}

void factor_vm::primitive_dispatch_stats()
{
	ctx->push(tag<byte_array>(byte_array_from_value(&dispatch_stats)));
}

void quotation_jit::emit_mega_cache_lookup(cell methods_, fixnum index, cell cache_)
{
	data_root<array> methods(methods_,parent);
	data_root<array> cache(cache_,parent);

	/* Load the object from the datastack. */
	emit_with_literal(parent->special_objects[PIC_LOAD],tag_fixnum(-index * sizeof(cell)));

	/* Do a cache lookup. */
	emit_with_literal(parent->special_objects[MEGA_LOOKUP],cache.value());
	
	/* If we end up here, the cache missed. */
	emit(parent->special_objects[JIT_PROLOG]);

	/* Push index, method table and cache on the stack. */
	push(methods.value());
	push(tag_fixnum(index));
	push(cache.value());
	word_call(parent->special_objects[MEGA_MISS_WORD]);

	/* Now the new method has been stored into the cache, and its on
	   the stack. */
	emit(parent->special_objects[JIT_EPILOG]);
	emit(parent->special_objects[JIT_EXECUTE]);
}

}
