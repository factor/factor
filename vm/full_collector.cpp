#include "master.hpp"

namespace factor
{

full_collector::full_collector(factor_vm *myvm_, bool trace_contexts_p_) :
	copying_collector<tenured_space,full_policy>(myvm_,myvm_->data->tenured,full_policy(myvm_)),
	trace_contexts_p(trace_contexts_p_) {}

void full_collector::go()
{
	trace_roots();
        if(trace_contexts_p) trace_contexts();
        cheneys_algorithm();
}

}
