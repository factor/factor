#include "master.hpp"

/* Multi-VM threading is not supported on NetBSD due to
http://gnats.netbsd.org/25563 */

namespace factor
{

factor_vm *global_vm;

void init_mvm()
{
	global_vm = NULL;
}

void register_vm_with_thread(factor_vm *vm)
{
	assert(!global_vm);
	global_vm = vm;
}

factor_vm *current_vm_p()
{
	return global_vm;
}

}
