#include "master.hpp"

namespace factor {

std::map<THREADHANDLE, factor_vm*> thread_vms;
static std::mutex thread_vms_mutex;

void register_thread_vm(THREADHANDLE thread, factor_vm* vm) {
  std::lock_guard<std::mutex> lock(thread_vms_mutex);
  thread_vms[thread] = vm;
}

void unregister_thread_vm(factor_vm* vm) {
  std::lock_guard<std::mutex> lock(thread_vms_mutex);
  auto iter = thread_vms.find(vm->thread);
  if (iter != thread_vms.end() && iter->second == vm)
    thread_vms.erase(iter);
}

factor_vm* thread_vm(THREADHANDLE thread) {
  std::lock_guard<std::mutex> lock(thread_vms_mutex);
  auto iter = thread_vms.find(thread);
  return iter == thread_vms.end() ? NULL : iter->second;
}

factor_vm* first_thread_vm() {
  std::lock_guard<std::mutex> lock(thread_vms_mutex);
  FACTOR_ASSERT(thread_vms.size() == 1);
  return thread_vms.begin()->second;
}

struct startargs {
  int argc;
  vm_char** argv;
};

// arg must be new'ed because we're going to delete it!
void* start_standalone_factor_thread(void* arg) {
  factor_vm* newvm = new_factor_vm();
  startargs* args = (startargs*)arg;
  int argc = args->argc;
  vm_char** argv = args->argv;
  delete args;
  newvm->start_standalone_factor(argc, argv);
  return 0;
}

VM_C_API THREADHANDLE start_standalone_factor_in_new_thread(int argc,
                                                            vm_char** argv) {
  startargs* args = new startargs;
  args->argc = argc;
  args->argv = argv;
  return start_thread(start_standalone_factor_thread, args);
}

}
