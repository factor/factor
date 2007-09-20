/* Set by the -S command line argument */
bool secure_gc;

typedef struct {
	CELL start;
	CELL size;
	CELL end;
} F_SEGMENT;

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

DECLARE_PRIMITIVE(data_room);
DECLARE_PRIMITIVE(size);
DECLARE_PRIMITIVE(begin_scan);
DECLARE_PRIMITIVE(next_object);
DECLARE_PRIMITIVE(end_scan);

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

	CELL gen_count;

	F_ZONE *generations;
	F_ZONE* semispaces;

	CELL *cards;
	CELL *cards_end;
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
#define CARD_BASE_MASK 0x3f
typedef u8 F_CARD;

/* A card is 64 bytes. 6 bits is sufficient to represent every
offset within the card */
#define CARD_SIZE 64
#define CARD_BITS 6
#define ADDR_CARD_MASK (CARD_SIZE-1)

INLINE void clear_card(F_CARD *c)
{
	*c = CARD_BASE_MASK; /* invalid value */
}

DLLEXPORT CELL cards_offset;
void init_cards_offset(void);

#define ADDR_TO_CARD(a) (F_CARD*)(((CELL)(a) >> CARD_BITS) + cards_offset)
#define CARD_TO_ADDR(c) (CELL*)(((CELL)(c) - cards_offset)<<CARD_BITS)

/* this is an inefficient write barrier. compiled definitions use a more
efficient one hand-coded in assembly. the write barrier must be called
any time we are potentially storing a pointer from an older generation
to a younger one */
INLINE void write_barrier(CELL address)
{
	F_CARD *c = ADDR_TO_CARD(address);
	*c |= (CARD_POINTS_TO_NURSERY | CARD_POINTS_TO_AGING);
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
	F_CARD *ptr = ADDR_TO_CARD(address);
	F_CARD c = *ptr;
	CELL b = (c & CARD_BASE_MASK);
	CELL a = (address & ADDR_CARD_MASK);
	*ptr = ((c & CARD_MARK_MASK) | ((b < a) ? b : a));
}

void clear_cards(CELL from, CELL to);
void collect_cards(void);

/* the 0th generation is where new objects are allocated. */
#define NURSERY 0
#define HAVE_NURSERY_P (data_heap->gen_count>1)
/* where objects hang around */
#define AGING (data_heap->gen_count-2)
#define HAVE_AGING_P (data_heap->gen_count>2)
/* the oldest generation */
#define TENURED (data_heap->gen_count-1)

/* used during garbage collection only */
F_ZONE *newspace;

/* new objects are allocated here */
DLLEXPORT F_ZONE *nursery;

INLINE bool in_zone(F_ZONE *z, CELL pointer)
{
	return pointer >= z->start && pointer < z->end;
}

CELL init_zone(F_ZONE *z, CELL size, CELL base);

void init_data_heap(CELL gens,
	CELL young_size,
	CELL aging_size,
	bool secure_gc_);

/* statistics */
s64 gc_time;
CELL minor_collections;
CELL cards_scanned;

/* only meaningful during a GC */
bool performing_gc;
CELL collecting_gen;
bool collecting_code;

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

/* test if the pointer is in generation being collected, or a younger one.
init_data_heap() arranges things so that the older generations are first,
so we have to check that the pointer occurs after the beginning of
the requested generation. */
INLINE bool should_copy(CELL untagged)
{
	if(in_zone(newspace,untagged))
		return false;
	if(collecting_gen == TENURED)
		return true;
	else if(HAVE_AGING_P && collecting_gen == AGING)
		return !in_zone(&data_heap->generations[TENURED],untagged);
	else if(HAVE_NURSERY_P && collecting_gen == NURSERY)
		return in_zone(&data_heap->generations[NURSERY],untagged);
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
	bool code_gc,
	bool growing_data_heap_,
	CELL requested_bytes);

/* If a runtime function needs to call another function which potentially
allocates memory, it must store any local variable references to Factor
objects on the root stack */
F_SEGMENT *extra_roots_region;
CELL extra_roots;

DEFPUSHPOP(root_,extra_roots)

#define REGISTER_ROOT(obj) root_push(obj)
#define UNREGISTER_ROOT(obj) obj = root_pop()

#define REGISTER_UNTAGGED(obj) root_push(obj ? tag_object(obj) : 0)
#define UNREGISTER_UNTAGGED(obj) obj = untag_object(root_pop())

#define REGISTER_STRING(obj) REGISTER_UNTAGGED(obj)
#define UNREGISTER_STRING(obj) UNREGISTER_UNTAGGED(obj)

/* We ignore strings which point outside the data heap, but we might be given
a char* which points inside the data heap, in which case it is a root, for
example if we call unbox_char_string() the result is placed in a byte array */
INLINE bool root_push_alien(const void *ptr)
{
	if((CELL)ptr > data_heap->segment->start
		&& (CELL)ptr < data_heap->segment->end)
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

INLINE void maybe_gc(CELL a)
{
	/* If we are requesting a huge object, grow immediately */
	if(nursery->size - ALLOT_BUFFER_ZONE <= a)
		garbage_collection(TENURED,false,true,a);
	/* If we have enough space in the nursery, just return.
	Otherwise, perform a GC - this may grow the heap if
	tenured space cannot hold all live objects from the nursery
	even after a full GC */
	else if(a + ALLOT_BUFFER_ZONE + nursery->here > nursery->end)
		garbage_collection(NURSERY,false,false,0);
	/* There is now sufficient room in the nursery for 'a' */
}

/*
 * It is up to the caller to fill in the object's fields in a meaningful
 * fashion!
 */
INLINE void* allot_object(CELL type, CELL length)
{
	maybe_gc(length);
	CELL* object = allot_zone(nursery,length);
	*object = tag_header(type);
	return object;
}

CELL collect_next(CELL scan);

DLLEXPORT void simple_gc(void);

void data_gc(void);

DECLARE_PRIMITIVE(data_gc);
DECLARE_PRIMITIVE(gc_time);
DECLARE_PRIMITIVE(become);
