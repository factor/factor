#include "master.hpp"

namespace factor
{

nursery_collector::nursery_collector(factor_vm *myvm_) :
	copying_collector<aging_space,nursery_policy>
	(myvm_,myvm_->data->aging,nursery_policy(myvm_)) {}

void nursery_collector::go()
{
	trace_roots();
	trace_contexts();
	trace_cards(data->tenured);
	trace_cards(data->aging);
	trace_code_heap_roots();
	cheneys_algorithm();
}

}
