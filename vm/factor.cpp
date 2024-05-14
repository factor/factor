#include "master.hpp"

namespace factor {

// Compile code in boot image so that we can execute the startup quotation
// Allocates memory
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
  // Kilobytes
  p->datastack_size = align_page(p->datastack_size << 10);
  p->retainstack_size = align_page(p->retainstack_size << 10);
  p->callstack_size = align_page(p->callstack_size << 10);
  p->callback_size = align_page(p->callback_size << 10);

  // Megabytes
  p->young_size <<= 20;
  p->aging_size <<= 20;
  p->tenured_size <<= 20;
  p->code_size <<= 20;

  // Disable GC during init as a sanity check
  gc_off = true;

  // OS-specific initialization
  early_init();

  p->executable_path = vm_executable_path();

  if (p->image_path == NULL) {
    if (embedded_image_p()) {
      p->embedded_image = true;
      p->image_path = safe_strdup(p->executable_path);
    } else
      p->image_path = default_image_path();
  }

  srand((unsigned int)nano_count());
  init_ffi();

  datastack_size = p->datastack_size;
  retainstack_size = p->retainstack_size;
  callstack_size = p->callstack_size;

  ctx = NULL;
  spare_ctx = new_context();

  callbacks = new callback_heap(p->callback_size, this);
  load_image(p);
  max_pic_size = (int)p->max_pic_size;
  special_objects[OBJ_CELL_SIZE] = tag_fixnum(sizeof(cell));
  special_objects[OBJ_ARGS] = false_object;
  special_objects[OBJ_EMBEDDED] = false_object;

#ifdef WINDOWS
#define VALID_HANDLE(handle,mode) (_fileno (handle)==-2 ? fopen ("nul",mode) : handle)
#else
#define VALID_HANDLE(handle,mode) (handle)
#endif

  cell aliens[][2] = {
    {OBJ_STDIN,           (cell)(VALID_HANDLE (stdin ,"r"))},
    {OBJ_STDOUT,          (cell)(VALID_HANDLE (stdout,"w"))},
    {OBJ_STDERR,          (cell)(VALID_HANDLE (stderr,"w"))},
    {OBJ_CPU,             (cell)FACTOR_CPU_STRING},
    {OBJ_EXECUTABLE,      (cell)safe_strdup(p->executable_path)},
    {OBJ_IMAGE,           (cell)safe_strdup(p->image_path)},
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

  // We can GC now
  gc_off = false;

  if (!to_boolean(special_objects[OBJ_STAGE2]))
    prepare_boot_image();

  if (p->signals)
    init_signals();

  if (p->console)
    open_console();

}

// Allocates memory
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
  p.init_from_args(argc, argv);
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
  newvm->start_standalone_factor(argc, argv);
  delete newvm;
}

}
