CELL heap_start;
CELL heap_end;

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

#define ADDR_TO_CARD(a) (CARD*)((((CELL)a-heap_start)>>CARD_BITS)+(CELL)cards)
#define CARD_TO_ADDR(c) (CELL*)((((CELL)c-(CELL)cards)<<CARD_BITS)+heap_start)

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
	*ptr = (card_marked(c) | MIN(card_base(c),(address & ADDR_CARD_MASK)));
}

void unmark_cards(CELL from, CELL to);
void clear_cards(CELL from, CELL to);
void collect_cards(CELL gen);
