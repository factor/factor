/* card marking write barrier. a card is a byte storing a mark flag,
and the offset (in cells) of the first object in the card.

the mark flag is set by the write barrier when an object in the
card has a slot written to.

the offset of the first object is set by the allocator. */

VM_C_API factor::cell cards_offset;
VM_C_API factor::cell decks_offset;

namespace factor
{

/* if CARD_POINTS_TO_NURSERY is set, CARD_POINTS_TO_AGING must also be set. */
#define CARD_POINTS_TO_NURSERY 0x80
#define CARD_POINTS_TO_AGING 0x40
#define CARD_MARK_MASK (CARD_POINTS_TO_NURSERY | CARD_POINTS_TO_AGING)
typedef u8 card;

#define CARD_BITS 8
#define CARD_SIZE (1<<CARD_BITS)
#define ADDR_CARD_MASK (CARD_SIZE-1)

inline static card *addr_to_card(cell a)
{
	return (card*)(((cell)(a) >> CARD_BITS) + cards_offset);
}

inline static cell card_to_addr(card *c)
{
	return ((cell)c - cards_offset) << CARD_BITS;
}

inline static cell card_offset(card *c)
{
	return *(c - (cell)data->cards + (cell)data->allot_markers);
}

typedef u8 card_deck;

#define DECK_BITS (CARD_BITS + 10)
#define DECK_SIZE (1<<DECK_BITS)
#define ADDR_DECK_MASK (DECK_SIZE-1)

inline static card_deck *addr_to_deck(cell a)
{
	return (card_deck *)(((cell)a >> DECK_BITS) + decks_offset);
}

inline static cell deck_to_addr(card_deck *c)
{
	return ((cell)c - decks_offset) << DECK_BITS;
}

inline static card *deck_to_card(card_deck *d)
{
	return (card *)((((cell)d - decks_offset) << (DECK_BITS - CARD_BITS)) + cards_offset);
}

#define INVALID_ALLOT_MARKER 0xff

extern cell allot_markers_offset;

inline static card *addr_to_allot_marker(object *a)
{
	return (card *)(((cell)a >> CARD_BITS) + allot_markers_offset);
}

/* the write barrier must be called any time we are potentially storing a
pointer from an older generation to a younger one */
inline static void write_barrier(object *obj)
{
	*addr_to_card((cell)obj) = CARD_MARK_MASK;
	*addr_to_deck((cell)obj) = CARD_MARK_MASK;
}

/* we need to remember the first object allocated in the card */
inline static void allot_barrier(object *address)
{
	card *ptr = addr_to_allot_marker(address);
	if(*ptr == INVALID_ALLOT_MARKER)
		*ptr = ((cell)address & ADDR_CARD_MASK);
}

}
