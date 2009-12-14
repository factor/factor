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
	u64 nanos = nano_count();
	if(nanos < last_nano_count) critical_error("Monotonic counter decreased",0);
	last_nano_count = nanos;
	box_unsigned_8(nanos);
}

void factor_vm::primitive_sleep()
{
	sleep_nanos(to_unsigned_8(dpop()));
}

}
