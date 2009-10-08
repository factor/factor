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
	collector.trace_cards(data->tenured);
	collector.trace_code_heap_roots();
	collector.cheneys_algorithm();
	update_dirty_code_blocks();

	nursery.here = nursery.start;
}

}
