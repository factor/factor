#include "master.hpp"

namespace factor
{

to_tenured_collector::to_tenured_collector(factor_vm *myvm_) :
	copying_collector<tenured_space,to_tenured_policy>(
		myvm_,
		&myvm_->gc_stats.aging_stats,
		myvm_->data->tenured,
		to_tenured_policy(myvm_)) {}

void factor_vm::collect_to_tenured()
{
	/* Copy live objects from aging space to tenured space. */
	to_tenured_collector collector(this);

	collector.trace_roots();
	collector.trace_contexts();
	collector.trace_cards(data->tenured,
		card_points_to_aging,
		dummy_unmarker());
	collector.trace_code_heap_roots(&code->points_to_aging);
	collector.cheneys_algorithm();
	update_code_heap_for_minor_gc(&code->points_to_aging);

	nursery.here = nursery.start;
	reset_generation(data->aging);
	code->points_to_nursery.clear();
	code->points_to_aging.clear();
}

}
