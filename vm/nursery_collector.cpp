#include "master.hpp"

namespace factor
{

nursery_collector::nursery_collector(factor_vm *myvm_) :
	copying_collector<aging_space,nursery_policy>(
		myvm_,
		&myvm_->gc_stats.nursery_stats,
		myvm_->data->aging,
		nursery_policy(myvm_)) {}

void factor_vm::collect_nursery()
{
	/* Copy live objects from the nursery (as determined by the root set and
	marked cards in aging and tenured) to aging space. */
	nursery_collector collector(this);

	collector.trace_roots();
	collector.trace_contexts();
	collector.trace_cards(data->tenured,
		card_points_to_nursery,
		simple_unmarker(card_points_to_nursery));
	collector.trace_cards(data->aging,
		card_points_to_nursery,
		simple_unmarker(card_mark_mask));
	collector.trace_code_heap_roots(&code->points_to_nursery);
	collector.cheneys_algorithm();
	update_code_heap_for_minor_gc(&code->points_to_nursery);

	nursery.here = nursery.start;
	code->points_to_nursery.clear();
}

}
