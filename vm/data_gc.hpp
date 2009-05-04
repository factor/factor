/* statistics */
struct F_GC_STATS {
	CELL collections;
	u64 gc_time;
	u64 max_gc_time;
	CELL object_count;
	u64 bytes_copied;
};

extern F_ZONE *newspace;

extern bool performing_compaction;
extern CELL collecting_gen;
extern bool collecting_aging_again;

extern CELL last_code_heap_scan;

void init_data_gc(void);

void gc(void);

inline static bool collecting_accumulation_gen_p(void)
{
	return ((HAVE_AGING_P
		&& collecting_gen == AGING
		&& !collecting_aging_again)
		|| collecting_gen == TENURED);
}

void copy_handle(CELL *handle);

void garbage_collection(volatile CELL gen,
	bool growing_data_heap_,
	CELL requested_bytes);

/* We leave this many bytes free at the top of the nursery so that inline
allocation (which does not call GC because of possible roots in volatile
registers) does not run out of memory */
#define ALLOT_BUFFER_ZONE 1024

/*
 * It is up to the caller to fill in the object's fields in a meaningful
 * fashion!
 */
inline static F_OBJECT *allot_object(F_HEADER header, CELL size)
{
#ifdef GC_DEBUG
	if(!gc_off)
		gc();
#endif

	F_OBJECT *object;

	if(nursery.size - ALLOT_BUFFER_ZONE > size)
	{
		/* If there is insufficient room, collect the nursery */
		if(nursery.here + ALLOT_BUFFER_ZONE + size > nursery.end)
			garbage_collection(NURSERY,false,0);

		CELL h = nursery.here;
		nursery.here = h + align8(size);
		object = (F_OBJECT *)h;
	}
	/* If the object is bigger than the nursery, allocate it in
	tenured space */
	else
	{
		F_ZONE *tenured = &data_heap->generations[TENURED];

		/* If tenured space does not have enough room, collect */
		if(tenured->here + size > tenured->end)
		{
			gc();
			tenured = &data_heap->generations[TENURED];
		}

		/* If it still won't fit, grow the heap */
		if(tenured->here + size > tenured->end)
		{
			garbage_collection(TENURED,true,size);
			tenured = &data_heap->generations[TENURED];
		}

		object = allot_zone(tenured,size);

		/* Allows initialization code to store old->new pointers
		without hitting the write barrier in the common case of
		a nursery allocation */
		write_barrier(object);
	}

	object->header = header;
	return object;
}

template<typename T> T *allot(CELL size)
{
	return (T *)allot_object(F_HEADER(T::type_number),size);
}

void copy_reachable_objects(CELL scan, CELL *end);

PRIMITIVE(gc);
PRIMITIVE(gc_stats);
void clear_gc_stats(void);
PRIMITIVE(clear_gc_stats);
PRIMITIVE(become);

extern bool growing_data_heap;

inline static void check_data_pointer(F_OBJECT *pointer)
{
#ifdef FACTOR_DEBUG
	if(!growing_data_heap)
	{
		assert((CELL)pointer >= data_heap->segment->start
		       && (CELL)pointer < data_heap->segment->end);
	}
#endif
}

inline static void check_tagged_pointer(CELL tagged)
{
#ifdef FACTOR_DEBUG
	if(!immediate_p(tagged))
	{
		F_OBJECT *object = untag<F_OBJECT>(tagged);
		check_data_pointer(object);
		object->header.hi_tag();
	}
#endif
}

VM_C_API void minor_gc(void);

