void gc(void);
DLLEXPORT void minor_gc(void);

/* used during garbage collection only */

F_ZONE *newspace;
bool performing_gc;
bool performing_compaction;
CELL collecting_gen;

/* if true, we collecting AGING space for the second time, so if it is still
full, we go on to collect TENURED */
bool collecting_aging_again;

/* in case a generation fills up in the middle of a gc, we jump back
up to try collecting the next generation. */
jmp_buf gc_jmp;

/* statistics */
typedef struct {
	CELL collections;
	u64 gc_time;
	u64 max_gc_time;
	CELL object_count;
	u64 bytes_copied;
} F_GC_STATS;

F_GC_STATS gc_stats[MAX_GEN_COUNT];
u64 cards_scanned;
u64 decks_scanned;
u64 card_scan_time;
CELL code_heap_scans;

/* What generation was being collected when copy_code_heap_roots() was last
called? Until the next call to add_code_block(), future
collections of younger generations don't have to touch the code
heap. */
CELL last_code_heap_scan;

/* sometimes we grow the heap */
bool growing_data_heap;
F_DATA_HEAP *old_data_heap;

INLINE bool collecting_accumulation_gen_p(void)
{
	return ((HAVE_AGING_P
		&& collecting_gen == AGING
		&& !collecting_aging_again)
		|| collecting_gen == TENURED);
}

/* test if the pointer is in generation being collected, or a younger one. */
INLINE bool should_copy(CELL untagged)
{
	if(in_zone(newspace,untagged))
		return false;
	if(collecting_gen == TENURED)
		return true;
	else if(HAVE_AGING_P && collecting_gen == AGING)
		return !in_zone(&data_heap->generations[TENURED],untagged);
	else if(collecting_gen == NURSERY)
		return in_zone(&nursery,untagged);
	else
	{
		critical_error("Bug in should_copy",untagged);
		return false;
	}
}

void copy_handle(CELL *handle);

void garbage_collection(volatile CELL gen,
	bool growing_data_heap_,
	CELL requested_bytes);

/* We leave this many bytes free at the top of the nursery so that inline
allocation (which does not call GC because of possible roots in volatile
registers) does not run out of memory */
#define ALLOT_BUFFER_ZONE 1024

/* If this is defined, we GC every 100 allocations. This catches missing local roots */
#ifdef GC_DEBUG
static int count;
#endif

/*
 * It is up to the caller to fill in the object's fields in a meaningful
 * fashion!
 */
INLINE void *allot_object(CELL type, CELL a)
{

#ifdef GC_DEBUG

	if(!gc_off)
	{
		if(count++ % 1000 == 0)
			gc();

	}
#endif

	CELL *object;

	if(nursery.size - ALLOT_BUFFER_ZONE > a)
	{
		/* If there is insufficient room, collect the nursery */
		if(nursery.here + ALLOT_BUFFER_ZONE + a > nursery.end)
			garbage_collection(NURSERY,false,0);

		CELL h = nursery.here;
		nursery.here = h + align8(a);
		object = (void*)h;
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

		object = allot_zone(tenured,a);

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
