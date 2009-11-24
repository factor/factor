#include "master.hpp"

namespace factor
{

to_tenured_collector::to_tenured_collector(factor_vm *parent_) :
	collector<tenured_space,to_tenured_policy>(
		parent_,
		parent_->data->tenured,
		to_tenured_policy(parent_)) {}

void to_tenured_collector::tenure_reachable_objects()
{
	std::vector<cell> *mark_stack = &parent->mark_stack;
	while(!mark_stack->empty())
	{
		cell ptr = mark_stack->back();
		mark_stack->pop_back();
		this->trace_object((object *)ptr);
	}
}

void factor_vm::collect_to_tenured()
{
	/* Copy live objects from aging space to tenured space. */
	to_tenured_collector collector(this);

	mark_stack.clear();

	collector.trace_roots();
	collector.trace_contexts();

	current_gc->event->started_card_scan();
	collector.trace_cards(data->tenured,
		card_points_to_aging,
		full_unmarker());
	current_gc->event->ended_card_scan(collector.cards_scanned,collector.decks_scanned);

	current_gc->event->started_code_scan();
	collector.trace_code_heap_roots(&code->points_to_aging);
	current_gc->event->ended_code_scan(collector.code_blocks_scanned);

	collector.tenure_reachable_objects();

	data->reset_generation(&nursery);
	data->reset_generation(data->aging);
	code->clear_remembered_set();
}

}
