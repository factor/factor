/* Set by the -S command line argument */
bool secure_gc;

bool in_page(CELL fault, CELL area, CELL area_size, int offset);

void *safe_malloc(size_t size);

typedef struct {
	CELL start;
	CELL size;
} F_SEGMENT;

/* set up guard pages to check for under/overflow.
size must be a multiple of the page size */
F_SEGMENT *alloc_segment(CELL size);
void dealloc_segment(F_SEGMENT *block);

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
typedef u8 F_CARD;

F_CARD *cards;
F_CARD *cards_end;

/* A card is 16 bytes (128 bits), 5 address bits per card.
it is important that 7 bits is sufficient to represent every
offset within the card */
#define CARD_SIZE 128
#define CARD_BITS 7
#define ADDR_CARD_MASK (CARD_SIZE-1)

INLINE F_CARD card_marked(F_CARD c)
{
	return c & CARD_MARK_MASK;
}

INLINE void unmark_card(F_CARD *c)
{
	*c &= CARD_BASE_MASK;
}

INLINE void clear_card(F_CARD *c)
{
	*c = CARD_BASE_MASK; /* invalid value */
}

INLINE u8 card_base(F_CARD c)
{
	return c & CARD_BASE_MASK;
}

#define ADDR_TO_CARD(a) (F_CARD*)(((CELL)a >> CARD_BITS) + cards_offset)
#define CARD_TO_ADDR(c) (CELL*)(((CELL)c - cards_offset)<<CARD_BITS)

/* this is an inefficient write barrier. compiled definitions use a more
efficient one hand-coded in assembly. the write barrier must be called
any time we are potentially storing a pointer from an older generation
to a younger one */
INLINE void write_barrier(CELL address)
{
	F_CARD *c = ADDR_TO_CARD(address);
	*c |= CARD_MARK_MASK;
}

#define SLOT(obj,slot) ((obj) + (slot) * CELLS)

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
} F_ZONE;

/* total number of generations. */
CELL gen_count;

/* the 0th generation is where new objects are allocated. */
#define NURSERY 0
/* the oldest generation */
#define TENURED (gen_count-1)

DLLEXPORT F_ZONE *generations;

/* used during garbage collection only */
F_ZONE *newspace;

#define tenured generations[TENURED]
#define nursery generations[NURSERY]

/* spare semi-space; rotates with tenured. */
F_ZONE prior;

INLINE bool in_zone(F_ZONE *z, CELL pointer)
{
	return pointer >= z->base && pointer < z->limit;
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

/* If a runtime function needs to call another function which potentially
allocates memory, it must store any local variable references to Factor
objects on the root stack */
F_SEGMENT *extra_roots_region;
CELL extra_roots;

DEFPUSHPOP(root_,extra_roots)

#define REGISTER_ROOT(obj) root_push(obj)
#define UNREGISTER_ROOT(obj) obj = root_pop()

#define REGISTER_ARRAY(obj) root_push(tag_object(obj))
#define UNREGISTER_ARRAY(obj) obj = untag_array_fast(root_pop())

#define REGISTER_STRING(obj) root_push(tag_object(obj))
#define UNREGISTER_STRING(obj) obj = untag_string_fast(root_pop())

/* We ignore strings which point outside the data heap, but we might be given
a char* which points inside the data heap, in which case it is a root, for
example if we call unbox_char_string() the result is placed in a byte array */
INLINE bool root_push_alien(const void *ptr)
{
	if((CELL)ptr > data_heap_start && (CELL)ptr < data_heap_end)
	{
		F_ARRAY *objptr = ((F_ARRAY *)ptr) - 1;
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

#define REGISTER_BIGNUM(obj) root_push(tag_bignum(obj))
#define UNREGISTER_BIGNUM(obj) obj = (untag_bignum_fast(root_pop()))

INLINE void *allot_zone(F_ZONE *z, CELL a)
{
	CELL h = z->here;
	z->here = h + align8(a);

	allot_barrier(h);
	return (void*)h;
}

INLINE void maybe_gc(CELL a)
{
	if(nursery.here + a > nursery.limit)
		garbage_collection(NURSERY,false);
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
void primitive_gc_time(void);
