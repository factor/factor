namespace factor
{

// I've had to copy inline implementations here to make dependencies work. Am hoping to move this code back into include files
// once the rest of the reentrant changes are done. -PD

//data_gc.hpp
inline bool factor_vm::collecting_accumulation_gen_p()
{
	return ((data->have_aging_p()
		&& collecting_gen == data->aging()
		&& !collecting_aging_again)
		|| collecting_gen == data->tenured());
}

inline object *factor_vm::allot_zone(zone *z, cell a)
{
	cell h = z->here;
	z->here = h + align8(a);
	object *obj = (object *)h;
	allot_barrier(obj);
	return obj;
}

/*
 * It is up to the caller to fill in the object's fields in a meaningful
 * fashion!
 */
inline object *factor_vm::allot_object(header header, cell size)
{
#ifdef GC_DEBUG
	if(!gc_off)
		gc();
#endif

	object *obj;

	if(nursery.size - allot_buffer_zone > size)
	{
		/* If there is insufficient room, collect the nursery */
		if(nursery.here + allot_buffer_zone + size > nursery.end)
			garbage_collection(data->nursery(),false,0);

		cell h = nursery.here;
		nursery.here = h + align8(size);
		obj = (object *)h;
	}
	/* If the object is bigger than the nursery, allocate it in
	tenured space */
	else
	{
		zone *tenured = &data->generations[data->tenured()];

		/* If tenured space does not have enough room, collect */
		if(tenured->here + size > tenured->end)
		{
			gc();
			tenured = &data->generations[data->tenured()];
		}

		/* If it still won't fit, grow the heap */
		if(tenured->here + size > tenured->end)
		{
			garbage_collection(data->tenured(),true,size);
			tenured = &data->generations[data->tenured()];
		}

		obj = allot_zone(tenured,size);

		/* Allows initialization code to store old->new pointers
		without hitting the write barrier in the common case of
		a nursery allocation */
		write_barrier(obj);
	}

	obj->h = header;
	return obj;
}

template<typename TYPE> TYPE *factor_vm::allot(cell size)
{
	return (TYPE *)allot_object(header(TYPE::type_number),size);
}

inline void factor_vm::check_data_pointer(object *pointer)
{
#ifdef FACTOR_DEBUG
	if(!growing_data_heap)
	{
		assert((cell)pointer >= data->seg->start
		       && (cell)pointer < data->seg->end);
	}
#endif
}

inline void factor_vm::check_tagged_pointer(cell tagged)
{
#ifdef FACTOR_DEBUG
	if(!immediate_p(tagged))
	{
		object *obj = untag<object>(tagged);
		check_data_pointer(obj);
		obj->h.hi_tag();
	}
#endif
}

//generic_arrays.hpp
template <typename TYPE> TYPE *factor_vm::allot_array_internal(cell capacity)
{
	TYPE *array = allot<TYPE>(array_size<TYPE>(capacity));
	array->capacity = tag_fixnum(capacity);
	return array;
}

template <typename TYPE> bool factor_vm::reallot_array_in_place_p(TYPE *array, cell capacity)
{
	return in_zone(&nursery,array) && capacity <= array_capacity(array);
}

template <typename TYPE> TYPE *factor_vm::reallot_array(TYPE *array_, cell capacity)
{
	gc_root<TYPE> array(array_,this);

	if(reallot_array_in_place_p(array.untagged(),capacity))
	{
		array->capacity = tag_fixnum(capacity);
		return array.untagged();
	}
	else
	{
		cell to_copy = array_capacity(array.untagged());
		if(capacity < to_copy)
			to_copy = capacity;

		TYPE *new_array = allot_array_internal<TYPE>(capacity);
	
		memcpy(new_array + 1,array.untagged() + 1,to_copy * TYPE::element_size);
		memset((char *)(new_array + 1) + to_copy * TYPE::element_size,
			0,(capacity - to_copy) * TYPE::element_size);

		return new_array;
	}
}

//arrays.hpp
inline void factor_vm::set_array_nth(array *array, cell slot, cell value)
{
#ifdef FACTOR_DEBUG
	assert(slot < array_capacity(array));
	assert(array->h.hi_tag() == ARRAY_TYPE);
	check_tagged_pointer(value);
#endif
	array->data()[slot] = value;
	write_barrier(array);
}

struct growable_array {
	cell count;
	gc_root<array> elements;

	growable_array(factor_vm *myvm, cell capacity = 10) : count(0), elements(myvm->allot_array(capacity,F),myvm) {}

	void add(cell elt);
	void trim();
};

//byte_arrays.hpp
struct growable_byte_array {
	cell count;
	gc_root<byte_array> elements;

	growable_byte_array(factor_vm *myvm,cell capacity = 40) : count(0), elements(myvm->allot_byte_array(capacity),myvm) { }

	void append_bytes(void *elts, cell len);
	void append_byte_array(cell elts);

	void trim();
};

//math.hpp
inline cell factor_vm::allot_integer(fixnum x)
{
	if(x < fixnum_min || x > fixnum_max)
		return tag<bignum>(fixnum_to_bignum(x));
	else
		return tag_fixnum(x);
}

inline cell factor_vm::allot_cell(cell x)
{
	if(x > (cell)fixnum_max)
		return tag<bignum>(cell_to_bignum(x));
	else
		return tag_fixnum(x);
}

inline cell factor_vm::allot_float(double n)
{
	boxed_float *flo = allot<boxed_float>(sizeof(boxed_float));
	flo->n = n;
	return tag(flo);
}

inline bignum *factor_vm::float_to_bignum(cell tagged)
{
	return double_to_bignum(untag_float(tagged));
}

inline double factor_vm::bignum_to_float(cell tagged)
{
	return bignum_to_double(untag<bignum>(tagged));
}

inline double factor_vm::untag_float(cell tagged)
{
	return untag<boxed_float>(tagged)->n;
}

inline double factor_vm::untag_float_check(cell tagged)
{
	return untag_check<boxed_float>(tagged)->n;
}

inline fixnum factor_vm::float_to_fixnum(cell tagged)
{
	return (fixnum)untag_float(tagged);
}

inline double factor_vm::fixnum_to_float(cell tagged)
{
	return (double)untag_fixnum(tagged);
}

//callstack.hpp
/* This is a little tricky. The iterator may allocate memory, so we
keep the callstack in a GC root and use relative offsets */
template<typename TYPE> void factor_vm::iterate_callstack_object(callstack *stack_, TYPE &iterator)
{
	gc_root<callstack> stack(stack_,this);
	fixnum frame_offset = untag_fixnum(stack->length) - sizeof(stack_frame);

	while(frame_offset >= 0)
	{
		stack_frame *frame = stack->frame_at(frame_offset);
		frame_offset -= frame->size;
		iterator(frame,this);
	}
}

//booleans.hpp
inline cell factor_vm::tag_boolean(cell untagged)
{
	return (untagged ? T : F);
}

// callstack.hpp
template<typename TYPE> void factor_vm::iterate_callstack(cell top, cell bottom, TYPE &iterator)
{
	stack_frame *frame = (stack_frame *)bottom - 1;

	while((cell)frame >= top)
	{
		iterator(frame,this);
		frame = frame_successor(frame);
	}
}

// data_heap.hpp
/* Every object has a regular representation in the runtime, which makes GC
much simpler. Every slot of the object until binary_payload_start is a pointer
to some other object. */
struct factor_vm;
inline void factor_vm::do_slots(cell obj, void (* iter)(cell *,factor_vm*))
{
	cell scan = obj;
	cell payload_start = binary_payload_start((object *)obj);
	cell end = obj + payload_start;

	scan += sizeof(cell);

	while(scan < end)
	{
		iter((cell *)scan,this);
		scan += sizeof(cell);
	}
}

// code_heap.hpp

inline void factor_vm::check_code_pointer(cell ptr)
{
#ifdef FACTOR_DEBUG
	assert(in_code_heap_p(ptr));
#endif
}

}
