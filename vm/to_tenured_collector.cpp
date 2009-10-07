#include "master.hpp"

namespace factor
{

to_tenured_collector::to_tenured_collector(factor_vm *myvm_) :
	copying_collector<tenured_space,to_tenured_policy>
	(myvm_,myvm_->data->tenured,to_tenured_policy(myvm_)) {}

void to_tenured_collector::go()
{
	trace_roots();
	trace_contexts();
	trace_cards(data->tenured);
	trace_code_heap_roots();
	cheneys_algorithm();
}

}
