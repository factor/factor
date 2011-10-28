#include "master.hpp"

namespace factor
{

factor_vm::factor_vm() :
	nursery(0,0),
	callback_id(0),
	c_to_factor_func(NULL),
	counting_profiler_p(false),
	sampling_profiler_p(false),
	safepoint_fep(false),
	safepoint_sample_count(0),
	safepoint_gc_sample_count(0),
	gc_off(false),
	current_gc(NULL),
	gc_events(NULL),
	fep_p(false),
	fep_disabled(false),
	full_output(false),
	last_nano_count(0),
	signal_callstack_seg(NULL)
{
	primitive_reset_dispatch_stats();
}

factor_vm::~factor_vm()
{
	delete_contexts();
	if(signal_callstack_seg)
	{
		delete signal_callstack_seg;
		signal_callstack_seg = NULL;
	}
	std::list<void **>::const_iterator iter = function_descriptors.begin();
	std::list<void **>::const_iterator end = function_descriptors.end();
	while(iter != end)
	{
		delete [] *iter;
		iter++;
	}
}

}
