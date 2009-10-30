#include "master.hpp"

namespace factor
{

aging_collector::aging_collector(factor_vm *parent_) :
	copying_collector<aging_space,aging_policy>(
		parent_,
		parent_->data->aging,
		aging_policy(parent_)) {}

void factor_vm::collect_aging()
{
	/* Promote objects referenced from tenured space to tenured space, copy
	everything else to the aging semi-space, and reset the nursery pointer. */
	{
		/* Change the op so that if we fail here, we proceed to a full
		tenured collection. We are collecting to tenured space, and
		cards were unmarked, so we can't proceed with a to_tenured
		collection. */
		current_gc->op = collect_to_tenured_op;

		to_tenured_collector collector(this);

		current_gc->event->started_code_scan();
		collector.trace_cards(data->tenured,
			card_points_to_aging,
			full_unmarker());
		current_gc->event->ended_card_scan(collector.cards_scanned,collector.decks_scanned);

		collector.tenure_reachable_objects();
	}
	{
		/* If collection fails here, do a to_tenured collection. */
		current_gc->op = collect_aging_op;

		std::swap(data->aging,data->aging_semispace);
		data->reset_generation(data->aging);

		aging_collector collector(this);

		collector.trace_roots();
		collector.trace_contexts();

		current_gc->event->started_code_scan();
		collector.trace_code_heap_roots(&code->points_to_aging);
		current_gc->event->ended_code_scan(collector.code_blocks_scanned);

		collector.cheneys_algorithm();

		current_gc->event->started_code_sweep();
		update_code_heap_for_minor_gc(&code->points_to_aging);
		current_gc->event->ended_code_sweep();

		data->reset_generation(&nursery);
		code->points_to_nursery.clear();
	}
}

}
