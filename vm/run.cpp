#include "master.hpp"

namespace factor
{

void factor_vm::primitive_exit()
{
	exit(to_fixnum(dpop()));
}

void factor_vm::primitive_micros()
{
	box_unsigned_8(current_micros());
}

void factor_vm::primitive_nanos()
{
	box_unsigned_8(current_nanos());
}

void factor_vm::primitive_sleep()
{
	sleep_micros(to_cell(dpop()));
}

}
