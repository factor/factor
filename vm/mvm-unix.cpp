#include "master.hpp"

namespace factor
{

pthread_key_t current_vm_tls_key;

void init_mvm()
{
	if(pthread_key_create(&current_vm_tls_key, NULL) != 0)
		fatal_error("pthread_key_create() failed",0);
}

void register_vm_with_thread(factor_vm *vm)
{
	pthread_setspecific(current_vm_tls_key,vm);
}

factor_vm *current_vm()
{
	factor_vm *vm = (factor_vm*)pthread_getspecific(current_vm_tls_key);
	assert(vm != NULL);
	return vm;
}

}
