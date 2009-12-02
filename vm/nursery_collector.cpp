#include "master.hpp"

namespace factor
{

nursery_collector::nursery_collector(factor_vm *parent_) :
	copying_collector<aging_space,nursery_policy>(
		parent_,
		parent_->data->aging,
		nursery_policy(parent_)) {}

void factor_vm::collect_nursery()
{
	/* Copy live objects from the nursery (as determined by the root set and
	marked cards in aging and tenured) to aging space. */
	nursery_collector collector(this);

	collector.trace_roots();
	collector.trace_contexts();

	current_gc->event->started_card_scan();
	collector.trace_cards(data->tenured,
		card_points_to_nursery,
		simple_unmarker(card_points_to_nursery));
	if(data->aging->here != data->aging->start)
	{
		collector.trace_cards(data->aging,
			card_points_to_nursery,
			full_unmarker());
	}
	current_gc->event->ended_card_scan(collector.cards_scanned,collector.decks_scanned);

	current_gc->event->started_code_scan();
	collector.trace_code_heap_roots(&code->points_to_nursery);
	current_gc->event->ended_code_scan(collector.code_blocks_scanned);

	collector.cheneys_algorithm();

	data->reset_generation(&nursery);
	code->points_to_nursery.clear();
}

}
