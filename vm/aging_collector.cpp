#include "master.hpp"

namespace factor
{

aging_collector::aging_collector(factor_vm *myvm_) :
	copying_collector<aging_space,aging_policy>
	(myvm_,myvm_->data->aging,aging_policy(myvm_)) {}

void aging_collector::go()
{
	trace_roots();
	trace_contexts();
	trace_cards(data->tenured);
	trace_code_heap_roots();
	cheneys_algorithm();
}

}
