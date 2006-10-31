bool in_page(CELL fault, CELL area, CELL area_size, int offset);

void *safe_malloc(size_t size);

typedef struct {
    CELL start;
    CELL size;
} BOUNDED_BLOCK;

/* set up guard pages to check for under/overflow.
size must be a multiple of the page size */
BOUNDED_BLOCK *alloc_bounded_block(CELL size);
void dealloc_bounded_block(BOUNDED_BLOCK *block);

CELL untagged_object_size(CELL pointer);
CELL unaligned_object_size(CELL pointer);
CELL object_size(CELL pointer);
CELL binary_payload_start(CELL pointer);
void primitive_data_room(void);
void primitive_size(void);
void primitive_begin_scan(void);
void primitive_next_object(void);
void primitive_end_scan(void);

CELL data_heap_start;
CELL data_heap_end;

/* card marking write barrier. a card is a byte storing a mark flag,
and the offset (in cells) of the first object in the card.

the mark flag is set by the write barrier when an object in the
card has a slot written to.

the offset of the first object is set by the allocator.
*/
#define CARD_MARK_MASK 0x80
#define CARD_BASE_MASK 0x7f
typedef u8 CARD;

CARD *cards;
CARD *cards_end;

/* A card is 16 bytes (128 bits), 5 address bits per card.
it is important that 7 bits is sufficient to represent every
offset within the card */
#define CARD_SIZE 128
#define CARD_BITS 7
#define ADDR_CARD_MASK (CARD_SIZE-1)

INLINE CARD card_marked(CARD c)
{
	return c & CARD_MARK_MASK;
}

INLINE void unmark_card(CARD *c)
{
	*c &= CARD_BASE_MASK;
}

INLINE void clear_card(CARD *c)
{
	*c = CARD_BASE_MASK; /* invalid value */
}

INLINE u8 card_base(CARD c)
{
	return c & CARD_BASE_MASK;
}

#define ADDR_TO_CARD(a) (CARD*)(((CELL)a >> CARD_BITS) + cards_offset)
#define CARD_TO_ADDR(c) (CELL*)(((CELL)c - cards_offset)<<CARD_BITS)

/* this is an inefficient write barrier. compiled definitions use a more
efficient one hand-coded in assembly. the write barrier must be called
any time we are potentially storing a pointer from an older generation
to a younger one */
INLINE void write_barrier(CELL address)
{
	CARD *c = ADDR_TO_CARD(address);
	*c |= CARD_MARK_MASK;
}

/* we need to remember the first object allocated in the card */
INLINE void allot_barrier(CELL address)
{
	CARD *ptr = ADDR_TO_CARD(address);
	CARD c = *ptr;
	CELL b = card_base(c);
	CELL a = (address & ADDR_CARD_MASK);
	*ptr = (card_marked(c) | ((b < a) ? b : a));
}

void unmark_cards(CELL from, CELL to);
void clear_cards(CELL from, CELL to);
void collect_cards(CELL gen);

/* generational copying GC divides memory into zones */
typedef struct {
	/* start of zone */
	CELL base;
	/* allocation pointer */
	CELL here;
	/* end of zone */
	CELL limit;
} ZONE;

/* total number of generations. */
CELL gen_count;

/* the 0th generation is where new objects are allocated. */
#define NURSERY 0
/* the oldest generation */
#define TENURED (gen_count-1)

DLLEXPORT ZONE *generations;

/* used during garbage collection only */
ZONE *newspace;

#define tenured generations[TENURED]
#define nursery generations[NURSERY]

/* spare semi-space; rotates with tenured. */
ZONE prior;

INLINE bool in_zone(ZONE* z, CELL pointer)
{
	return pointer >= z->base && pointer < z->limit;
}

CELL init_zone(ZONE *z, CELL size, CELL base);

void init_data_heap(CELL gen_count, CELL young_size, CELL aging_size);

/* statistics */
s64 gc_time;
CELL minor_collections;
CELL cards_scanned;

/* only meaningful during a GC */
CELL collecting_gen;
CELL collecting_gen_start;
bool collecting_code;

/* test if the pointer is in generation being collected, or a younger one.
init_data_heap() arranges things so that the older generations are first,
so we have to check that the pointer occurs after the beginning of
the requested generation. */
#define COLLECTING_GEN(ptr) (collecting_gen_start <= ptr)

INLINE bool should_copy(CELL untagged)
{
	if(collecting_gen == TENURED)
		return !in_zone(newspace,untagged);
	else
		return(in_zone(&prior,untagged) || COLLECTING_GEN(untagged));
}

CELL copy_object(CELL pointer);
#define COPY_OBJECT(lvalue) if(should_copy(lvalue)) lvalue = copy_object(lvalue)

INLINE void copy_handle(CELL *handle)
{
	COPY_OBJECT(*handle);
}

/* in case a generation fills up in the middle of a gc, we jump back
up to try collecting the next generation. */
jmp_buf gc_jmp;

/* A heap walk allows useful things to be done, like finding all
references to an object for debugging purposes. */
CELL heap_scan_ptr;

/* GC is off during heap walking */
bool gc_off;

void garbage_collection(CELL gen, bool code_gc);

#define REGISTER_ROOT(obj) rpush(obj)
#define UNREGISTER_ROOT(obj) obj = rpop()

/* WARNING: only call this from a context where all local variables
are also reachable via the GC roots, or gc_off is set to true. */
INLINE void maybe_gc(CELL size)
{
	if(nursery.here + size > nursery.limit)
		garbage_collection(NURSERY,false);
}

INLINE void *allot_zone(ZONE *z, CELL a)
{
	CELL h = z->here;
	z->here = h + align8(a);

	allot_barrier(h);
	return (void*)h;
}

INLINE void *allot(CELL a)
{
	maybe_gc(a);
	return allot_zone(&nursery,a);
}

/*
 * It is up to the caller to fill in the object's fields in a meaningful
 * fashion!
 */
INLINE void* allot_object(CELL type, CELL length)
{
	CELL* object = allot(length);
	*object = tag_header(type);
	return object;
}

void update_cards_offset(void);
CELL collect_next(CELL scan);
void primitive_data_gc(void);
void maybe_gc(CELL size);
DLLEXPORT void simple_gc(void);
void primitive_gc_time(void);
