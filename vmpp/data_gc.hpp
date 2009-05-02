void init_data_gc(void);

void gc(void);
DLLEXPORT void minor_gc(void);

/* statistics */
typedef struct {
	CELL collections;
	u64 gc_time;
	u64 max_gc_time;
	CELL object_count;
	u64 bytes_copied;
} F_GC_STATS;

extern F_ZONE *newspace;

extern bool performing_compaction;
extern CELL collecting_gen;
extern bool collecting_aging_again;

INLINE bool collecting_accumulation_gen_p(void)
{
	return ((HAVE_AGING_P
		&& collecting_gen == AGING
		&& !collecting_aging_again)
		|| collecting_gen == TENURED);
}

extern CELL last_code_heap_scan;

/* test if the pointer is in generation being collected, or a younger one. */
bool should_copy_p(CELL untagged);

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
INLINE void *allot_object(CELL type, CELL a)
{
#ifdef GC_DEBUG
	if(!gc_off)
		gc();
#endif

	CELL *object;

	if(nursery.size - ALLOT_BUFFER_ZONE > a)
	{
		/* If there is insufficient room, collect the nursery */
		if(nursery.here + ALLOT_BUFFER_ZONE + a > nursery.end)
			garbage_collection(NURSERY,false,0);

		CELL h = nursery.here;
		nursery.here = h + align8(a);
		object = (CELL*)h;
	}
	/* If the object is bigger than the nursery, allocate it in
	tenured space */
	else
	{
		F_ZONE *tenured = &data_heap->generations[TENURED];

		/* If tenured space does not have enough room, collect */
		if(tenured->here + a > tenured->end)
		{
			gc();
			tenured = &data_heap->generations[TENURED];
		}

		/* If it still won't fit, grow the heap */
		if(tenured->here + a > tenured->end)
		{
			garbage_collection(TENURED,true,a);
			tenured = &data_heap->generations[TENURED];
		}

		object = (CELL *)allot_zone(tenured,a);

		/* We have to do this */
		allot_barrier((CELL)object);

		/* Allows initialization code to store old->new pointers
		without hitting the write barrier in the common case of
		a nursery allocation */
		write_barrier((CELL)object);
	}

	*object = tag_header(type);
	return object;
}

void copy_reachable_objects(CELL scan, CELL *end);

void primitive_gc(void);
void primitive_gc_stats(void);
void clear_gc_stats(void);
void primitive_clear_gc_stats(void);
void primitive_become(void);

extern bool growing_data_heap;

INLINE void check_data_pointer(CELL pointer)
{
#ifdef FACTOR_DEBUG
	if(!growing_data_heap)
	{
		assert(pointer >= data_heap->segment->start
		       && pointer < data_heap->segment->end);
	}
#endif
}
