namespace factor
{

/* Set by the -securegc command line argument */
extern bool secure_gc;

/* generational copying GC divides memory into zones */
struct zone {
	/* allocation pointer is 'here'; its offset is hardcoded in the
	compiler backends */
	cell start;
	cell here;
	cell size;
	cell end;
};

struct data_heap {
	segment *seg;

	cell young_size;
	cell aging_size;
	cell tenured_size;

	cell gen_count;

	zone *generations;
	zone *semispaces;

	cell *allot_markers;
	cell *allot_markers_end;

	cell *cards;
	cell *cards_end;

	cell *decks;
	cell *decks_end;
};

extern data_heap *data;

/* the 0th generation is where new objects are allocated. */
#define NURSERY 0
/* where objects hang around */
#define AGING (data->gen_count-2)
#define HAVE_AGING_P (data->gen_count>2)
/* the oldest generation */
#define TENURED (data->gen_count-1)

#define MIN_GEN_COUNT 1
#define MAX_GEN_COUNT 3

inline static bool in_zone(zone *z, object *pointer)
{
	return (cell)pointer >= z->start && (cell)pointer < z->end;
}

cell init_zone(zone *z, cell size, cell base);

void init_card_decks();

data_heap *grow_data_heap(data_heap *data, cell requested_bytes);

void dealloc_data_heap(data_heap *data);

void clear_cards(cell from, cell to);
void clear_decks(cell from, cell to);
void clear_allot_markers(cell from, cell to);
void reset_generation(cell i);
void reset_generations(cell from, cell to);

void set_data_heap(data_heap *data_heap_);

void init_data_heap(cell gens,
	cell young_size,
	cell aging_size,
	cell tenured_size,
	bool secure_gc_);

/* set up guard pages to check for under/overflow.
size must be a multiple of the page size */
segment *alloc_segment(cell size);
void dealloc_segment(segment *block);

cell untagged_object_size(object *pointer);
cell unaligned_object_size(object *pointer);
cell binary_payload_start(object *pointer);
cell object_size(cell tagged);

void begin_scan();
cell next_object();

PRIMITIVE(data_room);
PRIMITIVE(size);

PRIMITIVE(begin_scan);
PRIMITIVE(next_object);
PRIMITIVE(end_scan);

/* GC is off during heap walking */
extern bool gc_off;

cell find_all_words();

/* Every object has a regular representation in the runtime, which makes GC
much simpler. Every slot of the object until binary_payload_start is a pointer
to some other object. */
inline static void do_slots(cell obj, void (* iter)(cell *))
{
	cell scan = obj;
	cell payload_start = binary_payload_start((object *)obj);
	cell end = obj + payload_start;

	scan += sizeof(cell);

	while(scan < end)
	{
		iter((cell *)scan);
		scan += sizeof(cell);
	}
}

}

/* new objects are allocated here */
VM_C_API factor::zone nursery;
