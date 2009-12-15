#include "master.hpp"

namespace factor
{

factor_vm::factor_vm() :
	nursery(0,0),
	profiling_p(false),
	gc_off(false),
	current_gc(NULL),
	gc_events(NULL),
	fep_disabled(false),
	full_output(false),
	last_nano_count(0)
{
	primitive_reset_dispatch_stats();
}

}
