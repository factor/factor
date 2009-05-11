/* card marking write barrier. a card is a byte storing a mark flag,
and the offset (in cells) of the first object in the card.

the mark flag is set by the write barrier when an object in the
card has a slot written to.

the offset of the first object is set by the allocator. */

VM_C_API factor::cell cards_offset;
VM_C_API factor::cell decks_offset;

namespace factor
{

/* if card_points_to_nursery is set, card_points_to_aging must also be set. */
static const cell card_points_to_nursery = 0x80;
static const cell card_points_to_aging = 0x40;
static const cell card_mark_mask = (card_points_to_nursery | card_points_to_aging);
typedef u8 card;

static const cell card_bits = 8;
static const cell card_size = (1<<card_bits);
static const cell addr_card_mask = (card_size-1);

inline static card *addr_to_card(cell a)
{
	return (card*)(((cell)(a) >> card_bits) + cards_offset);
}

inline static cell card_to_addr(card *c)
{
	return ((cell)c - cards_offset) << card_bits;
}

inline static cell card_offset(card *c)
{
	return *(c - (cell)data->cards + (cell)data->allot_markers);
}

typedef u8 card_deck;

static const cell deck_bits = (card_bits + 10);
static const cell deck_size = (1<<deck_bits);
static const cell addr_deck_mask = (deck_size-1);

inline static card_deck *addr_to_deck(cell a)
{
	return (card_deck *)(((cell)a >> deck_bits) + decks_offset);
}

inline static cell deck_to_addr(card_deck *c)
{
	return ((cell)c - decks_offset) << deck_bits;
}

inline static card *deck_to_card(card_deck *d)
{
	return (card *)((((cell)d - decks_offset) << (deck_bits - card_bits)) + cards_offset);
}

static const cell invalid_allot_marker = 0xff;

extern cell allot_markers_offset;

inline static card *addr_to_allot_marker(object *a)
{
	return (card *)(((cell)a >> card_bits) + allot_markers_offset);
}

/* the write barrier must be called any time we are potentially storing a
pointer from an older generation to a younger one */
inline static void write_barrier(object *obj)
{
	*addr_to_card((cell)obj) = card_mark_mask;
	*addr_to_deck((cell)obj) = card_mark_mask;
}

/* we need to remember the first object allocated in the card */
inline static void allot_barrier(object *address)
{
	card *ptr = addr_to_allot_marker(address);
	if(*ptr == invalid_allot_marker)
		*ptr = ((cell)address & addr_card_mask);
}

}
