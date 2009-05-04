namespace factor
{

/* statistics */
struct gc_stats {
	cell collections;
	u64 gc_time;
	u64 max_gc_time;
	cell object_count;
	u64 bytes_copied;
};

extern zone *newspace;

extern bool performing_compaction;
extern cell collecting_gen;
extern bool collecting_aging_again;

extern cell last_code_heap_scan;

void init_data_gc(void);

void gc(void);

inline static bool collecting_accumulation_gen_p(void)
{
	return ((HAVE_AGING_P
		&& collecting_gen == AGING
		&& !collecting_aging_again)
		|| collecting_gen == TENURED);
}

void copy_handle(cell *handle);

void garbage_collection(volatile cell gen,
	bool growing_data_heap_,
	cell requested_bytes);

/* We leave this many bytes free at the top of the nursery so that inline
allocation (which does not call GC because of possible roots in volatile
registers) does not run out of memory */
#define ALLOT_BUFFER_ZONE 1024

inline static object *allot_zone(zone *z, cell a)
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
inline static object *allot_object(header header, cell size)
{
#ifdef GC_DEBUG
	if(!gc_off)
		gc();
#endif

	object *obj;

	if(nursery.size - ALLOT_BUFFER_ZONE > size)
	{
		/* If there is insufficient room, collect the nursery */
		if(nursery.here + ALLOT_BUFFER_ZONE + size > nursery.end)
			garbage_collection(NURSERY,false,0);

		cell h = nursery.here;
		nursery.here = h + align8(size);
		obj = (object *)h;
	}
	/* If the object is bigger than the nursery, allocate it in
	tenured space */
	else
	{
		zone *tenured = &data->generations[TENURED];

		/* If tenured space does not have enough room, collect */
		if(tenured->here + size > tenured->end)
		{
			gc();
			tenured = &data->generations[TENURED];
		}

		/* If it still won't fit, grow the heap */
		if(tenured->here + size > tenured->end)
		{
			garbage_collection(TENURED,true,size);
			tenured = &data->generations[TENURED];
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

template<typename T> T *allot(cell size)
{
	return (T *)allot_object(header(T::type_number),size);
}

void copy_reachable_objects(cell scan, cell *end);

PRIMITIVE(gc);
PRIMITIVE(gc_stats);
void clear_gc_stats(void);
PRIMITIVE(clear_gc_stats);
PRIMITIVE(become);

extern bool growing_data_heap;

inline static void check_data_pointer(object *pointer)
{
#ifdef FACTOR_DEBUG
	if(!growing_data_heap)
	{
		assert((cell)pointer >= data->seg->start
		       && (cell)pointer < data->seg->end);
	}
#endif
}

inline static void check_tagged_pointer(cell tagged)
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

VM_C_API void minor_gc(void);

}
