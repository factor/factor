#include "factor.h"

/* scan all the objects in the card */
INLINE void collect_card(CARD *ptr, CELL here)
{
	CARD c = *ptr;
	CELL offset = (c & CARD_BASE_MASK);
	CELL card_scan = (CELL)CARD_TO_ADDR(ptr) + offset;
	CELL card_end = (CELL)CARD_TO_ADDR(ptr + 1);

	if(offset == 0x7f)
	{
		if(c == 0xff)
			critical_error("bad card",c);
		else
			return;
	}

	while(card_scan < card_end && card_scan < here)
		card_scan = collect_next(card_scan);
	
	cards_scanned++;
}

INLINE void collect_gen_cards(CELL gen)
{
	CARD *ptr = ADDR_TO_CARD(generations[gen].base);
	CELL here = generations[gen].here;
	CARD *last_card = ADDR_TO_CARD(here);
	
	if(generations[gen].here == generations[gen].limit)
		last_card--;
	
	for(; ptr <= last_card; ptr++)
	{
		if(card_marked(*ptr))
			collect_card(ptr,here);
	}
}

void unmark_cards(CELL from, CELL to)
{
	CARD *ptr = ADDR_TO_CARD(generations[from].base);
	CARD *last_card = ADDR_TO_CARD(generations[to].here);
	if(generations[to].here == generations[to].limit)
		last_card--;
	for(; ptr <= last_card; ptr++)
		unmark_card(ptr);
}

void clear_cards(CELL from, CELL to)
{
	/* NOTE: reverse order due to heap layout. */
	CARD *last_card = ADDR_TO_CARD(generations[from].limit);
	CARD *ptr = ADDR_TO_CARD(generations[to].base);
	for(; ptr < last_card; ptr++)
		clear_card(ptr);
}

/* scan cards in all generations older than the one being collected */
void collect_cards(CELL gen)
{
	int i;
	for(i = gen + 1; i < GC_GENERATIONS; i++)
		collect_gen_cards(i);
}
