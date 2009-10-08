#include "master.hpp"

namespace factor
{

nursery_collector::nursery_collector(factor_vm *myvm_) :
	copying_collector<aging_space,nursery_policy>
	(myvm_,myvm_->data->aging,nursery_policy(myvm_)) {}

void factor_vm::collect_nursery()
{
	nursery_collector collector(this);

	collector.trace_roots();
	collector.trace_contexts();
	collector.trace_cards(data->tenured);
	collector.trace_cards(data->aging);
	collector.trace_code_heap_roots();
	collector.cheneys_algorithm();

	update_dirty_code_blocks();

	nursery.here = nursery.start;
}

}
