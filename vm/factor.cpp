#include "master.hpp"

namespace factor {

void init_globals() { init_mvm(); }

void factor_vm::default_parameters(vm_parameters* p) {
  p->embedded_image = false;
  p->image_path = NULL;

  p->datastack_size = 32 * sizeof(cell);
  p->retainstack_size = 32 * sizeof(cell);

#if defined(FACTOR_PPC)
  p->callstack_size = 256 * sizeof(cell);
#else
  p->callstack_size = 128 * sizeof(cell);
#endif

  p->code_size = 64;
  p->young_size = sizeof(cell) / 4;
  p->aging_size = sizeof(cell) / 2;
  p->tenured_size = 24 * sizeof(cell);

  p->max_pic_size = 3;

  p->fep = false;
  p->signals = true;

#ifdef WINDOWS
  p->console = GetConsoleWindow() != NULL;
#else
  p->console = true;
#endif

  p->callback_size = 256;
}

bool factor_vm::factor_arg(const vm_char* str, const vm_char* arg,
                           cell* value) {
  int val;
  if (SSCANF(str, arg, &val) > 0) {
    *value = val;
    return true;
  }
  return false;
}

void factor_vm::init_parameters_from_args(vm_parameters* p, int argc,
                                          vm_char** argv) {
  default_parameters(p);
  p->executable_path = argv[0];

  int i = 0;

  for (i = 1; i < argc; i++) {
    vm_char* arg = argv[i];
    if (STRCMP(arg, STRING_LITERAL("--")) == 0)
      break;
    else if (factor_arg(arg, STRING_LITERAL("-datastack=%d"),
                        &p->datastack_size))
      ;
    else if (factor_arg(arg, STRING_LITERAL("-retainstack=%d"),
                        &p->retainstack_size))
      ;
    else if (factor_arg(arg, STRING_LITERAL("-callstack=%d"),
                        &p->callstack_size))
      ;
    else if (factor_arg(arg, STRING_LITERAL("-young=%d"), &p->young_size))
      ;
    else if (factor_arg(arg, STRING_LITERAL("-aging=%d"), &p->aging_size))
      ;
    else if (factor_arg(arg, STRING_LITERAL("-tenured=%d"), &p->tenured_size))
      ;
    else if (factor_arg(arg, STRING_LITERAL("-codeheap=%d"), &p->code_size))
      ;
    else if (factor_arg(arg, STRING_LITERAL("-pic=%d"), &p->max_pic_size))
      ;
    else if (factor_arg(arg, STRING_LITERAL("-callbacks=%d"),
                        &p->callback_size))
      ;
    else if (STRNCMP(arg, STRING_LITERAL("-i="), 3) == 0)
      p->image_path = arg + 3;
    else if (STRCMP(arg, STRING_LITERAL("-fep")) == 0)
      p->fep = true;
    else if (STRCMP(arg, STRING_LITERAL("-nosignals")) == 0)
      p->signals = false;
    else if (STRCMP(arg, STRING_LITERAL("-console")) == 0)
      p->console = true;
  }
}

/* Compile code in boot image so that we can execute the startup quotation */
/* Allocates memory */
void factor_vm::prepare_boot_image() {
  std::cout << "*** Stage 2 early init... " << std::flush;

  // Compile all words.
  data_root<array> words(instances(WORD_TYPE), this);

  cell n_words = array_capacity(words.untagged());
  for (cell i = 0; i < n_words; i++) {
    data_root<word> word(array_nth(words.untagged(), i), this);

    FACTOR_ASSERT(!word->entry_point);
    jit_compile_word(word.value(), word->def, false);
  }
  update_code_heap_words(true);

  // Initialize all quotations
  data_root<array> quotations(instances(QUOTATION_TYPE), this);

  cell n_quots = array_capacity(quotations.untagged());
  for (cell i = 0; i < n_quots; i++) {
    data_root<quotation> quot(array_nth(quotations.untagged(), i), this);

    if (!quot->entry_point)
      quot->entry_point = lazy_jit_compile_entry_point();
  }

  special_objects[OBJ_STAGE2] = special_objects[OBJ_CANONICAL_TRUE];

  std::cout << "done" << std::endl;
}

void factor_vm::init_factor(vm_parameters* p) {
  /* Kilobytes */
  p->datastack_size = align_page(p->datastack_size << 10);
  p->retainstack_size = align_page(p->retainstack_size << 10);
  p->callstack_size = align_page(p->callstack_size << 10);
  p->callback_size = align_page(p->callback_size << 10);

  /* Megabytes */
  p->young_size <<= 20;
  p->aging_size <<= 20;
  p->tenured_size <<= 20;
  p->code_size <<= 20;

  /* Disable GC during init as a sanity check */
  gc_off = true;

  /* OS-specific initialization */
  early_init();

  const vm_char* executable_path = vm_executable_path();

  if (executable_path)
    p->executable_path = executable_path;

  if (p->image_path == NULL) {
    if (embedded_image_p()) {
      p->embedded_image = true;
      p->image_path = p->executable_path;
    } else
      p->image_path = default_image_path();
  }

  srand((unsigned int)nano_count());
  init_ffi();
  init_contexts(p->datastack_size, p->retainstack_size, p->callstack_size);
  callbacks = new callback_heap(p->callback_size, this);
  load_image(p);
  init_c_io();
  init_inline_caching((int)p->max_pic_size);
  special_objects[OBJ_CELL_SIZE] = tag_fixnum(sizeof(cell));
  special_objects[OBJ_ARGS] = false_object;
  special_objects[OBJ_EMBEDDED] = false_object;

  cell aliens[][2] = {
    {OBJ_CPU,             (cell)FACTOR_CPU_STRING},
    {OBJ_EXECUTABLE,      (cell)p->executable_path},
    {OBJ_OS,              (cell)FACTOR_OS_STRING},
    {OBJ_VM_COMPILE_TIME, (cell)FACTOR_COMPILE_TIME},
    {OBJ_VM_COMPILER,     (cell)FACTOR_COMPILER_VERSION},
    {OBJ_VM_GIT_LABEL,    (cell)FACTOR_STRINGIZE(FACTOR_GIT_LABEL)},
    {OBJ_VM_VERSION,      (cell)FACTOR_STRINGIZE(FACTOR_VERSION)},
#if defined(WINDOWS)
    {WIN_EXCEPTION_HANDLER, (cell)&factor::exception_handler}
#endif
  };
  int n_items = sizeof(aliens) / sizeof(cell[2]);
  for (int n = 0; n < n_items; n++) {
    cell idx = aliens[n][0];
    special_objects[idx] = allot_alien(false_object, aliens[n][1]);
  }

  /* We can GC now */
  gc_off = false;

  if (!to_boolean(special_objects[OBJ_STAGE2]))
    prepare_boot_image();

  if (p->signals)
    init_signals();

  if (p->console)
    open_console();

}

/* Allocates memory */
void factor_vm::pass_args_to_factor(int argc, vm_char** argv) {
  growable_array args(this);

  for (fixnum i = 0; i < argc; i++)
    args.add(allot_alien(false_object, (cell)argv[i]));

  args.trim();
  special_objects[OBJ_ARGS] = args.elements.value();
}

void factor_vm::stop_factor() {
  c_to_factor_toplevel(special_objects[OBJ_SHUTDOWN_QUOT]);
}

char* factor_vm::factor_eval_string(char* string) {
  void* func = alien_offset(special_objects[OBJ_EVAL_CALLBACK]);
  CODE_TO_FUNCTION_POINTER(func);
  return ((char * (*)(char*)) func)(string);
}

void factor_vm::factor_eval_free(char* result) { free(result); }

void factor_vm::factor_yield() {
  void* func = alien_offset(special_objects[OBJ_YIELD_CALLBACK]);
  CODE_TO_FUNCTION_POINTER(func);
  ((void(*)()) func)();
}

void factor_vm::factor_sleep(long us) {
  void* func = alien_offset(special_objects[OBJ_SLEEP_CALLBACK]);
  CODE_TO_FUNCTION_POINTER(func);
  ((void(*)(long)) func)(us);
}

void factor_vm::start_standalone_factor(int argc, vm_char** argv) {
  vm_parameters p;
  init_parameters_from_args(&p, argc, argv);
  init_factor(&p);
  pass_args_to_factor(argc, argv);

  if (p.fep)
    factorbug();

  c_to_factor_toplevel(special_objects[OBJ_STARTUP_QUOT]);
}

factor_vm* new_factor_vm() {
  THREADHANDLE thread = thread_id();
  factor_vm* newvm = new factor_vm(thread);
  register_vm_with_thread(newvm);
  thread_vms[thread] = newvm;

  return newvm;
}

VM_C_API void start_standalone_factor(int argc, vm_char** argv) {
  factor_vm* newvm = new_factor_vm();
  return newvm->start_standalone_factor(argc, argv);
}

}
