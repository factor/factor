#include "../master.hpp"

using namespace factor;

static void check(bool condition, const char* message) {
  if (!condition) {
    std::cerr << message << std::endl;
    ::exit(1);
  }
}

int main(int argc, char** argv) {
  factor_vm vm{THREADHANDLE()};
  std::fill(vm.special_objects, vm.special_objects + special_object_count,
            false_object);
  vm.set_data_heap(new data_heap(&vm.nursery, deck_size, deck_size,
                                16 * deck_size));
  for (int i = 0; i < 120; ++i)
    vm.active_contexts.insert(new context(deck_size, deck_size, deck_size));
  // Ensure the current context survives even when it sorts after all others.
  vm.ctx = *vm.active_contexts.rbegin();

  if (argc > 1 && strcmp(argv[1], "fatal") == 0) {
    init_mvm();
    register_vm_with_thread(&vm);
    std::cout << "Unit Test: fatal diagnostic regression" << std::endl;
    fatal_error("diagnostic regression", 1234);
    return 1;
  }

  std::ostringstream brief, full, current_stack;
  vm.dump_memory_layout(brief, false);
  vm.dump_memory_layout(full);
  current_stack << (void*)vm.ctx->datastack_seg->start;
  std::string brief_text = brief.str(), full_text = full.str();
  check(std::count(brief_text.begin(), brief_text.end(), '\n') < 30,
        "Fatal memory layout could crowd test output out of Mason's log tail");
  check(std::count(full_text.begin(), full_text.end(), '\n') > 400,
        "Debugger no longer shows every context");
  check(brief_text.find("Contexts: 120") != std::string::npos,
        "Fatal memory layout lost the total context count");
  check(brief_text.find(current_stack.str()) != std::string::npos,
        "Fatal memory layout lost the current context");
  check(brief_text.find("Nursery") != std::string::npos &&
            brief_text.find("Tenured") != std::string::npos,
        "Fatal memory layout lost the heap ranges");
  vm.ctx = NULL;
  std::cout << "Diagnostic tests passed" << std::endl;
}
