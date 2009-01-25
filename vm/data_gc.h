/* Set by the -S command line argument */
bool secure_gc;

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

void gc(void);
DLLEXPORT void minor_gc(void);

/* generational copying GC divides memory into zones */
typedef struct {
	/* allocation pointer is 'here'; its offset is hardcoded in the
	compiler backends, see core/compiler/.../allot.factor */
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

/* card marking write barrier. a card is a byte storing a mark flag,
and the offset (in cells) of the first object in the card.

the mark flag is set by the write barrier when an object in the
card has a slot written to.

the offset of the first object is set by the allocator. */

/* if CARD_POINTS_TO_NURSERY is set, CARD_POINTS_TO_AGING must also be set. */
#define CARD_POINTS_TO_NURSERY 0x80
#define CARD_POINTS_TO_AGING 0x40
#define CARD_MARK_MASK (CARD_POINTS_TO_NURSERY | CARD_POINTS_TO_AGING)
typedef u8 F_CARD;

#define CARD_BITS 8
#define CARD_SIZE (1<<CARD_BITS)
#define ADDR_CARD_MASK (CARD_SIZE-1)

DLLEXPORT CELL cards_offset;

#define ADDR_TO_CARD(a) (F_CARD*)(((CELL)(a) >> CARD_BITS) + cards_offset)
#define CARD_TO_ADDR(c) (CELL*)(((CELL)(c) - cards_offset)<<CARD_BITS)

typedef u8 F_DECK;

#define DECK_BITS (CARD_BITS + 10)
#define DECK_SIZE (1<<DECK_BITS)
#define ADDR_DECK_MASK (DECK_SIZE-1)

DLLEXPORT CELL decks_offset;

#define ADDR_TO_DECK(a) (F_DECK*)(((CELL)(a) >> DECK_BITS) + decks_offset)
#define DECK_TO_ADDR(c) (CELL*)(((CELL)(c) - decks_offset) << DECK_BITS)

#define DECK_TO_CARD(d) (F_CARD*)((((CELL)(d) - decks_offset) << (DECK_BITS - CARD_BITS)) + cards_offset)

#define ADDR_TO_ALLOT_MARKER(a) (F_CARD*)(((CELL)(a) >> CARD_BITS) + allot_markers_offset)
#define CARD_OFFSET(c) (*((c) - (CELL)data_heap->cards + (CELL)data_heap->allot_markers))

#define INVALID_ALLOT_MARKER 0xff

DLLEXPORT CELL allot_markers_offset;

void init_card_decks(void);

/* the write barrier must be called any time we are potentially storing a
pointer from an older generation to a younger one */
INLINE void write_barrier(CELL address)
{
	*ADDR_TO_CARD(address) = CARD_MARK_MASK;
	*ADDR_TO_DECK(address) = CARD_MARK_MASK;
}

#define SLOT(obj,slot) (UNTAG(obj) + (slot) * CELLS)

INLINE void set_slot(CELL obj, CELL slot, CELL value)
{
	put(SLOT(obj,slot),value);
	write_barrier(obj);
}

/* we need to remember the first object allocated in the card */
INLINE void allot_barrier(CELL address)
{
	F_CARD *ptr = ADDR_TO_ALLOT_MARKER(address);
	if(*ptr == INVALID_ALLOT_MARKER)
		*ptr = (address & ADDR_CARD_MASK);
}

void clear_cards(CELL from, CELL to);

/* the 0th generation is where new objects are allocated. */
#define NURSERY 0
#define HAVE_NURSERY_P (data_heap->gen_count>1)
/* where objects hang around */
#define AGING (data_heap->gen_count-2)
#define HAVE_AGING_P (data_heap->gen_count>2)
/* the oldest generation */
#define TENURED (data_heap->gen_count-1)

#define MIN_GEN_COUNT 1
#define MAX_GEN_COUNT 3

/* used during garbage collection only */
F_ZONE *newspace;

/* new objects are allocated here */
DLLEXPORT F_ZONE nursery;

INLINE bool in_zone(F_ZONE *z, CELL pointer)
{
	return pointer >= z->start && pointer < z->end;
}

CELL init_zone(F_ZONE *z, CELL size, CELL base);

void init_data_heap(CELL gens,
	CELL young_size,
	CELL aging_size,
	CELL tenured_size,
	bool secure_gc_);

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
CELL code_heap_scans;

/* only meaningful during a GC */
bool performing_gc;
CELL collecting_gen;

/* if true, we collecting AGING space for the second time, so if it is still
full, we go on to collect TENURED */
bool collecting_aging_again;

INLINE bool collecting_accumulation_gen_p(void)
{
	return ((HAVE_AGING_P
		&& collecting_gen == AGING
		&& !collecting_aging_again)
		|| collecting_gen == TENURED);
}

/* What generation was being collected when collect_literals() was last
called? Until the next call to primitive_add_compiled_block(), future
collections of younger generations don't have to touch the code
heap. */
CELL last_code_heap_scan;

/* sometimes we grow the heap */
bool growing_data_heap;
F_DATA_HEAP *old_data_heap;

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

/* test if the pointer is in generation being collected, or a younger one. */
INLINE bool should_copy(CELL untagged)
{
	if(in_zone(newspace,untagged))
		return false;
	if(collecting_gen == TENURED)
		return true;
	else if(HAVE_AGING_P && collecting_gen == AGING)
		return !in_zone(&data_heap->generations[TENURED],untagged);
	else if(HAVE_NURSERY_P && collecting_gen == NURSERY)
		return in_zone(&nursery,untagged);
	else
	{
		critical_error("Bug in should_copy",untagged);
		return false;
	}
}

void copy_handle(CELL *handle);

/* in case a generation fills up in the middle of a gc, we jump back
up to try collecting the next generation. */
jmp_buf gc_jmp;

/* A heap walk allows useful things to be done, like finding all
references to an object for debugging purposes. */
CELL heap_scan_ptr;

/* GC is off during heap walking */
bool gc_off;

void garbage_collection(volatile CELL gen,
	bool growing_data_heap_,
	CELL requested_bytes);

/* If a runtime function needs to call another function which potentially
allocates memory, it must store any local variable references to Factor
objects on the root stack */

/* GC locals: stores addresses of pointers to objects. The GC updates these
pointers, so you can do

REGISTER_ROOT(some_local);

... allocate memory ...

foo(some_local);

...

UNREGISTER_ROOT(some_local); */
F_SEGMENT *gc_locals_region;
CELL gc_locals;

DEFPUSHPOP(gc_local_,gc_locals)

#define REGISTER_ROOT(obj) gc_local_push((CELL)&obj)
#define UNREGISTER_ROOT(obj) \
	{ \
		if(gc_local_pop() != (CELL)&obj) \
			critical_error("Mismatched REGISTER_ROOT/UNREGISTER_ROOT",0); \
	}

/* Extra roots: stores pointers to objects in the heap. Requires extra work
(you have to unregister before accessing the object) but more flexible. */
F_SEGMENT *extra_roots_region;
CELL extra_roots;

DEFPUSHPOP(root_,extra_roots)

#define REGISTER_UNTAGGED(obj) root_push(obj ? tag_object(obj) : 0)
#define UNREGISTER_UNTAGGED(obj) obj = untag_object(root_pop())

INLINE bool in_data_heap_p(CELL ptr)
{
	return (ptr >= data_heap->segment->start
		&& ptr <= data_heap->segment->end);
}

/* We ignore strings which point outside the data heap, but we might be given
a char* which points inside the data heap, in which case it is a root, for
example if we call unbox_char_string() the result is placed in a byte array */
INLINE bool root_push_alien(const void *ptr)
{
	if(in_data_heap_p((CELL)ptr))
	{
		F_BYTE_ARRAY *objptr = ((F_BYTE_ARRAY *)ptr) - 1;
		if(objptr->header == tag_header(BYTE_ARRAY_TYPE))
		{
			root_push(tag_object(objptr));
			return true;
		}
	}

	return false;
}

#define REGISTER_C_STRING(obj) \
	bool obj##_root = root_push_alien(obj)
#define UNREGISTER_C_STRING(obj) \
	if(obj##_root) obj = alien_offset(root_pop())

#define REGISTER_BIGNUM(obj) if(obj) root_push(tag_bignum(obj))
#define UNREGISTER_BIGNUM(obj) if(obj) obj = (untag_object(root_pop()))

INLINE void *allot_zone(F_ZONE *z, CELL a)
{
	CELL h = z->here;
	z->here = h + align8(a);
	return (void*)h;
}

/* We leave this many bytes free at the top of the nursery so that inline
allocation (which does not call GC because of possible roots in volatile
registers) does not run out of memory */
#define ALLOT_BUFFER_ZONE 1024

/*
 * It is up to the caller to fill in the object's fields in a meaningful
 * fashion!
 */
INLINE void* allot_object(CELL type, CELL a)
{
	CELL *object;

	if(HAVE_NURSERY_P && nursery.size - ALLOT_BUFFER_ZONE > a)
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
void primitive_gc_reset(void);
void primitive_become(void);

CELL find_all_words(void);
