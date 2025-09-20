// card marking write barrier. a card is a byte storing a mark flag,
// and the offset (in cells) of the first object in the card.

// the mark flag is set by the write barrier when an object in the
// card has a slot written to.

// the offset of the first object is set by the allocator.

namespace factor {

// if card_points_to_nursery is set, card_points_to_aging must also be set.
static const cell card_points_to_nursery = 0x80;
static const cell card_points_to_aging = 0x40;
static const cell card_mark_mask =
    (card_points_to_nursery | card_points_to_aging);
typedef uint8_t card;

static const cell card_bits = 8;
static const cell card_size = 1 << card_bits;
static const cell addr_card_mask = card_size - 1;

typedef uint8_t card_deck;

static const cell deck_bits = card_bits + 10;
// Number of bytes on the heap a deck addresses. Each deck has 1024
// cards. So 256 kb.
static const cell deck_size = 1 << deck_bits;
static const cell cards_per_deck = 1 << 10;

constexpr inline cell addr_to_card(cell a) { return a >> card_bits; }

constexpr inline cell addr_to_deck(cell a) { return a >> deck_bits; }
}
