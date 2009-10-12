#include "master.hpp"

namespace factor
{

factor_vm::factor_vm() :
	nursery(0,0),
	profiling_p(false),
	secure_gc(false),
	gc_off(false),
	current_gc(NULL),
	fep_disabled(false),
	full_output(false)
	{ }

}
