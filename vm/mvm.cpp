#include "master.hpp"

namespace factor {

std::map<THREADHANDLE, factor_vm*> thread_vms;

struct startargs {
  int argc;
  vm_char** argv;
};

// arg ownership is transferred to the thread
void* start_standalone_factor_thread(void* arg) {
  factor_vm* newvm = new_factor_vm();
  std::unique_ptr<startargs> args((startargs*)arg);
  int argc = args->argc;
  vm_char** argv = args->argv;
  newvm->start_standalone_factor(argc, argv);
  return 0;
}

VM_C_API THREADHANDLE start_standalone_factor_in_new_thread(int argc,
                                                            vm_char** argv) {
  auto args = std::make_unique<startargs>();
  args->argc = argc;
  args->argv = argv;
  return start_thread(start_standalone_factor_thread, args.release());
}

}
