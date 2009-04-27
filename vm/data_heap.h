/* Set by the -securegc command line argument */
bool secure_gc;

/* generational copying GC divides memory into zones */
typedef struct {
	/* allocation pointer is 'here'; its offset is hardcoded in the
	compiler backends*/
	CELL start;
	CELL here;
	CELL size;
	CELL end;
} F_ZONE;

typedef struct {
	F_SEGMENT *segment;

	CELL young_size;
	CELL aging_size;
	CELL tenured_size;

	CELL gen_count;

	F_ZONE *generations;
	F_ZONE* semispaces;

	CELL *allot_markers;
	CELL *allot_markers_end;

	CELL *cards;
	CELL *cards_end;

	CELL *decks;
	CELL *decks_end;
} F_DATA_HEAP;

F_DATA_HEAP *data_heap;

/* the 0th generation is where new objects are allocated. */
#define NURSERY 0
/* where objects hang around */
#define AGING (data_heap->gen_count-2)
#define HAVE_AGING_P (data_heap->gen_count>2)
/* the oldest generation */
#define TENURED (data_heap->gen_count-1)

#define MIN_GEN_COUNT 1
#define MAX_GEN_COUNT 3

/* new objects are allocated here */
DLLEXPORT F_ZONE nursery;

INLINE bool in_zone(F_ZONE *z, CELL pointer)
{
	return pointer >= z->start && pointer < z->end;
}

CELL init_zone(F_ZONE *z, CELL size, CELL base);

void init_card_decks(void);

F_DATA_HEAP *grow_data_heap(F_DATA_HEAP *data_heap, CELL requested_bytes);

void dealloc_data_heap(F_DATA_HEAP *data_heap);

void clear_cards(CELL from, CELL to);
void clear_decks(CELL from, CELL to);
void clear_allot_markers(CELL from, CELL to);
void reset_generation(CELL i);
void reset_generations(CELL from, CELL to);

void set_data_heap(F_DATA_HEAP *data_heap_);

void init_data_heap(CELL gens,
	CELL young_size,
	CELL aging_size,
	CELL tenured_size,
	bool secure_gc_);

/* set up guard pages to check for under/overflow.
size must be a multiple of the page size */
F_SEGMENT *alloc_segment(CELL size);
void dealloc_segment(F_SEGMENT *block);

CELL untagged_object_size(CELL pointer);
CELL unaligned_object_size(CELL pointer);
CELL object_size(CELL pointer);
CELL binary_payload_start(CELL pointer);

void begin_scan(void);
CELL next_object(void);

void primitive_data_room(void);
void primitive_size(void);

void primitive_begin_scan(void);
void primitive_next_object(void);
void primitive_end_scan(void);

/* A heap walk allows useful things to be done, like finding all
references to an object for debugging purposes. */
CELL heap_scan_ptr;

/* GC is off during heap walking */
bool gc_off;

INLINE bool in_data_heap_p(CELL ptr)
{
	return (ptr >= data_heap->segment->start
		&& ptr <= data_heap->segment->end);
}

INLINE void *allot_zone(F_ZONE *z, CELL a)
{
	CELL h = z->here;
	z->here = h + align8(a);
	return (void*)h;
}

CELL find_all_words(void);

/* Every object has a regular representation in the runtime, which makes GC
much simpler. Every slot of the object until binary_payload_start is a pointer
to some other object. */
INLINE void do_slots(CELL obj, void (* iter)(CELL *))
{
	CELL scan = obj;
	CELL payload_start = binary_payload_start(obj);
	CELL end = obj + payload_start;

	scan += CELLS;

	while(scan < end)
	{
		iter((CELL *)scan);
		scan += CELLS;
	}
}
