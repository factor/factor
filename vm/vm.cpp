#include "master.hpp"

namespace factor
{

factor_vm::factor_vm() :
	nursery(0,0),
	callback_id(0),
	c_to_factor_func(NULL),
	profiling_p(false),
	gc_off(false),
	current_gc(NULL),
	gc_events(NULL),
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
}

}
