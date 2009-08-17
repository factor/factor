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

inline card *factorvm::addr_to_card(cell a)
{
	return (card*)(((cell)(a) >> card_bits) + cards_offset);
}

inline card *addr_to_card(cell a)
{
	return vm->addr_to_card(a);
}

inline cell factorvm::card_to_addr(card *c)
{
	return ((cell)c - cards_offset) << card_bits;
}

inline cell card_to_addr(card *c)
{
	return vm->card_to_addr(c);
}

inline cell factorvm::card_offset(card *c)
{
	return *(c - (cell)data->cards + (cell)data->allot_markers);
}

inline cell card_offset(card *c)
{
	return vm->card_offset(c);
}

typedef u8 card_deck;

static const cell deck_bits = (card_bits + 10);
static const cell deck_size = (1<<deck_bits);
static const cell addr_deck_mask = (deck_size-1);

inline card_deck *factorvm::addr_to_deck(cell a)
{
	return (card_deck *)(((cell)a >> deck_bits) + decks_offset);
}

inline card_deck *addr_to_deck(cell a)
{
	return vm->addr_to_deck(a);
}

inline cell factorvm::deck_to_addr(card_deck *c)
{
	return ((cell)c - decks_offset) << deck_bits;
}

inline cell deck_to_addr(card_deck *c)
{
	return vm->deck_to_addr(c);
}

inline card *factorvm::deck_to_card(card_deck *d)
{
	return (card *)((((cell)d - decks_offset) << (deck_bits - card_bits)) + cards_offset);
}

inline card *deck_to_card(card_deck *d)
{
	return vm->deck_to_card(d);
}

static const cell invalid_allot_marker = 0xff;

extern cell allot_markers_offset;

inline card *factorvm::addr_to_allot_marker(object *a)
{
	return (card *)(((cell)a >> card_bits) + allot_markers_offset);
}

inline card *addr_to_allot_marker(object *a)
{
	return vm->addr_to_allot_marker(a);
}

/* the write barrier must be called any time we are potentially storing a
pointer from an older generation to a younger one */
inline void factorvm::write_barrier(object *obj)
{
	*addr_to_card((cell)obj) = card_mark_mask;
	*addr_to_deck((cell)obj) = card_mark_mask;
}

inline void write_barrier(object *obj)
{
	return vm->write_barrier(obj);
}

/* we need to remember the first object allocated in the card */
inline void factorvm::allot_barrier(object *address)
{
	card *ptr = addr_to_allot_marker(address);
	if(*ptr == invalid_allot_marker)
		*ptr = ((cell)address & addr_card_mask);
}

inline void allot_barrier(object *address)
{
	return vm->allot_barrier(address);
}

}
