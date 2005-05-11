/* macros for reading/writing memory, useful when working around
C's type system */
INLINE CELL get(CELL where)
{
	return *((CELL*)where);
}

INLINE void put(CELL where, CELL what)
{
	*((CELL*)where) = what;
}

INLINE u16 cget(CELL where)
{
	return *((u16*)where);
}

INLINE void cput(CELL where, u16 what)
{
	*((u16*)where) = what;
}

INLINE BYTE bget(CELL where)
{
	return *((BYTE*)where);
}

INLINE void bput(CELL where, BYTE what)
{
	*((BYTE*)where) = what;
}

/* generational copying GC divides memory into zones */
typedef struct {
	/* start of zone */
	CELL base;
	/* allocation pointer */
	CELL here;
	/* only for nursery: when it gets this full, call GC */
	CELL alarm;
	/* end of zone */
	CELL limit;
} ZONE;

INLINE bool in_zone(ZONE* z, CELL pointer)
{
	return pointer >= z->base && pointer < z->limit;
}

/* total number of generations. */
#define GC_GENERATIONS 3
/* the 0th generation is where new objects are allocated. */
#define NURSERY 0
/* the oldest generation */
#define TENURED (GC_GENERATIONS-1)

ZONE generations[GC_GENERATIONS];

CELL heap_start;

#define active generations[TENURED]

/* spare semi-space; rotates with generations[TENURED]. */
ZONE prior;

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
#define CARD_SIZE 16
#define CARD_BITS 4
#define CARD_MASK CARD_SIZE-1

INLINE CARD card_marked(CARD c)
{
	return c & CARD_MARK_MASK;
}

INLINE void clear_card(CARD *c)
{
	*c = CARD_BASE_MASK;
}

INLINE u8 card_base(CARD c)
{
	return c & CARD_BASE_MASK;
}

INLINE void rebase_card(CARD *c, u8 base)
{
	*c = base;
}

#define ADDR_TO_CARD(a) (CARD*)(((a-heap_start)>>CARD_BITS)+(CELL)cards)
#define CARD_TO_ADDR(c) (CELL*)(((c-(CELL)cards)<<CARD_BITS)+heap_start)

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
	CARD *c = ADDR_TO_CARD(address);
	/* we need to remember the first object allocated in the
	card */
	rebase_card(c,MIN(card_base(*c),address & CARD_MASK));
}

bool allot_profiling;

/* set up guard pages to check for under/overflow.
size must be a multiple of the page size */
void* alloc_guarded(CELL size);

void dump_generations(void);
CELL init_zone(ZONE *z, CELL size, CELL base);
void init_arena(CELL young_size, CELL aging_size);
void flip_zones();

void allot_profile_step(CELL a);

INLINE CELL align8(CELL a)
{
	return ((a & 7) == 0) ? a : ((a + 8) & ~7);
}

INLINE void* allot(CELL a)
{
	CELL h = active.here;
	allot_barrier(h);
	active.here += align8(a);
	if(allot_profiling)
		allot_profile_step(align8(a));
	return (void*)h;
}

bool in_zone(ZONE* z, CELL pointer);

void primitive_room(void);
void primitive_allot_profiling(void);
void primitive_address(void);
void primitive_size(void);

/* A heap walk allows useful things to be done, like finding all
references to an object for debugging purposes. */
CELL heap_scan_ptr;

/* End of heap when walk was started; prevents infinite loop if
walk consing */
CELL heap_scan_end;

void primitive_begin_scan(void);
void primitive_next_object(void);
void primitive_end_scan(void);
