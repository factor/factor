#include "master.hpp"

namespace factor
{

void factor_vm::c_to_factor_toplevel(cell quot)
{
	/* 32-bit Windows SEH is set up in basis/cpu/x86/32/windows/bootstrap.factor */
	c_to_factor(quot);
}

}
