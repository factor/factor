/* Set by the -securegc command line argument */
extern bool secure_gc;

/* generational copying GC divides memory into zones */
struct F_ZONE {
	/* allocation pointer is 'here'; its offset is hardcoded in the
	compiler backends */
	CELL start;
	CELL here;
	CELL size;
	CELL end;
};

struct F_DATA_HEAP {
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
};

extern F_DATA_HEAP *data_heap;

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
extern F_ZONE nursery;

inline static bool in_zone(F_ZONE *z, F_OBJECT *pointer)
{
	return (CELL)pointer >= z->start && (CELL)pointer < z->end;
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

CELL untagged_object_size(F_OBJECT *pointer);
CELL unaligned_object_size(F_OBJECT *pointer);
CELL binary_payload_start(F_OBJECT *pointer);
CELL object_size(CELL tagged);

void begin_scan(void);
CELL next_object(void);

PRIMITIVE(data_room);
PRIMITIVE(size);

PRIMITIVE(begin_scan);
PRIMITIVE(next_object);
PRIMITIVE(end_scan);

/* GC is off during heap walking */
extern bool gc_off;

inline static F_OBJECT *allot_zone(F_ZONE *z, CELL a)
{
	CELL h = z->here;
	z->here = h + align8(a);
	F_OBJECT *object = (F_OBJECT *)h;
	allot_barrier(object);
	return object;
}

CELL find_all_words(void);

/* Every object has a regular representation in the runtime, which makes GC
much simpler. Every slot of the object until binary_payload_start is a pointer
to some other object. */
inline static void do_slots(CELL obj, void (* iter)(CELL *))
{
	CELL scan = obj;
	CELL payload_start = binary_payload_start((F_OBJECT *)obj);
	CELL end = obj + payload_start;

	scan += CELLS;

	while(scan < end)
	{
		iter((CELL *)scan);
		scan += CELLS;
	}
}

