#include "master.hpp"

namespace factor
{

void factor_vm::primitive_exit()
{
	exit(to_fixnum(dpop()));
}

void factor_vm::primitive_system_micros()
{
	box_unsigned_8(system_micros());
}

void factor_vm::primitive_nano_count()
{
	box_unsigned_8(nano_count());
}

void factor_vm::primitive_sleep()
{
	sleep_nanos(factor_vm::to_unsigned_8(dpop()));
}

}
