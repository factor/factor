#include "master.hpp"

namespace factor
{

aging_collector::aging_collector(factor_vm *myvm_) :
	copying_collector<aging_space,aging_policy>
	(myvm_,myvm_->data->aging,aging_policy(myvm_)) {}

void factor_vm::collect_aging()
{
	std::swap(data->aging,data->aging_semispace);
	reset_generation(data->aging);

	aging_collector collector(this);

	collector.trace_roots();
	collector.trace_contexts();
	collector.trace_cards(data->tenured,
		card_points_to_aging,
		complex_unmarker(card_mark_mask,card_points_to_nursery));
	collector.trace_code_heap_roots(&code->points_to_aging);
	collector.cheneys_algorithm();
	update_dirty_code_blocks(&code->points_to_aging);

	nursery.here = nursery.start;
	code->points_to_nursery.clear();
}

}
