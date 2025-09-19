#include "master.hpp"

namespace factor {

std::map<THREADHANDLE, factor_vm*> thread_vms;

struct startargs {
  int argc;
  vm_char** argv;
};

// arg must be new'ed because we're going to delete it!
void* start_standalone_factor_thread(void* arg) {
  factor_vm* newvm = new_factor_vm();
  startargs* args = static_cast<startargs*>(arg);
  int argc = args->argc;
  vm_char** argv = args->argv;
  delete args;
  newvm->start_standalone_factor(argc, argv);
  return 0;
}

VM_C_API THREADHANDLE start_standalone_factor_in_new_thread(int argc,
                                                            vm_char** argv) {
  startargs* args = new startargs{.argc = argc, .argv = argv};
  return start_thread(start_standalone_factor_thread, args);
}

}
