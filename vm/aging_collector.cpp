#include "master.hpp"

namespace factor
{

aging_collector::aging_collector(factor_vm *myvm_) :
	copying_collector<aging_space,aging_policy>(
		myvm_,
		&myvm_->gc_stats.aging_stats,
		myvm_->data->aging,
		aging_policy(myvm_)) {}

void factor_vm::collect_aging()
{
	{
		/* Change the op so that if we fail here, we proceed to a full
		tenured collection. We are collecting to tenured space, and
		cards were unmarked, so we can't proceed with a to_tenured
		collection. */
		current_gc->op = collect_to_tenured_op;

		to_tenured_collector collector(this);
		collector.trace_cards(data->tenured,
			card_points_to_aging,
			simple_unmarker(card_mark_mask));
		collector.cheneys_algorithm();
	}
	{
		/* If collection fails here, do a to_tenured collection. */
		current_gc->op = collect_aging_op;

		std::swap(data->aging,data->aging_semispace);
		reset_generation(data->aging);

		aging_collector collector(this);

		collector.trace_roots();
		collector.trace_contexts();
		collector.trace_code_heap_roots(&code->points_to_aging);
		collector.cheneys_algorithm();
		update_dirty_code_blocks(&code->points_to_aging);

		nursery.here = nursery.start;
		code->points_to_nursery.clear();
	}
}

}
