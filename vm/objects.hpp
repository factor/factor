namespace factor {

// Special object count and identifiers must be kept in sync with:
//   core/kernel/kernel.factor
//   basis/bootstrap/image/image.factor

static const cell special_object_count = 80;

enum special_object {
  OBJ_WALKER_HOOK = 3, /* non-local exit hook, used by library only */
  OBJ_CALLCC_1,        /* used to pass the value in callcc1 */

  ERROR_HANDLER_QUOT = 5, /* quotation called when VM throws an error */
  OBJ_ERROR,              /* a marker consed onto kernel errors */

  OBJ_CELL_SIZE = 7, /* sizeof(cell) */
  OBJ_CPU,           /* CPU architecture */
  OBJ_OS,            /* operating system name */

  OBJ_ARGS = 10, /* command line arguments */
  OBJ_STDIN,     /* stdin FILE* handle */
  OBJ_STDOUT,    /* stdout FILE* handle */

  OBJ_IMAGE = 13, /* image path name */
  OBJ_EXECUTABLE, /* runtime executable path name */

  OBJ_EMBEDDED = 15,  /* are we embedded in another app? */
  OBJ_EVAL_CALLBACK,  /* used when Factor is embedded in a C app */
  OBJ_YIELD_CALLBACK, /* used when Factor is embedded in a C app */
  OBJ_SLEEP_CALLBACK, /* used when Factor is embedded in a C app */

  OBJ_STARTUP_QUOT = 20, /* startup quotation */
  OBJ_GLOBAL,            /* global namespace */
  OBJ_SHUTDOWN_QUOT,     /* shutdown quotation */

  /* Quotation compilation in quotations.c */
  JIT_PROLOG = 23,
  JIT_PRIMITIVE_WORD,
  JIT_PRIMITIVE,
  JIT_WORD_JUMP,
  JIT_WORD_CALL,
  JIT_IF_WORD,
  JIT_IF,
  JIT_SAFEPOINT,
  JIT_EPILOG,
  JIT_RETURN,
  JIT_PROFILING,
  JIT_PUSH_IMMEDIATE,
  JIT_DIP_WORD,
  JIT_DIP,
  JIT_2DIP_WORD,
  JIT_2DIP,
  JIT_3DIP_WORD,
  JIT_3DIP,
  JIT_EXECUTE,
  JIT_DECLARE_WORD,

  /* External entry points */
  C_TO_FACTOR_WORD = 43,
  LAZY_JIT_COMPILE_WORD,
  UNWIND_NATIVE_FRAMES_WORD,
  GET_FPU_STATE_WORD,
  SET_FPU_STATE_WORD,
  SIGNAL_HANDLER_WORD,
  LEAF_SIGNAL_HANDLER_WORD,
  FFI_SIGNAL_HANDLER_WORD,
  FFI_LEAF_SIGNAL_HANDLER_WORD,

  /* Incremented on every modify-code-heap call; invalidates call( inline
     caching */
  REDEFINITION_COUNTER = 52,

  /* Callback stub generation in callbacks.c */
  CALLBACK_STUB = 53,

  /* Polymorphic inline cache generation in inline_cache.c */
  PIC_LOAD = 54,
  PIC_TAG,
  PIC_TUPLE,
  PIC_CHECK_TAG,
  PIC_CHECK_TUPLE,
  PIC_HIT,
  PIC_MISS_WORD,
  PIC_MISS_TAIL_WORD,

  /* Megamorphic cache generation in dispatch.c */
  MEGA_LOOKUP = 62,
  MEGA_LOOKUP_WORD,
  MEGA_MISS_WORD,

  OBJ_UNDEFINED = 65, /* default quotation for undefined words */

  OBJ_STDERR = 66, /* stderr FILE* handle */

  OBJ_STAGE2 = 67, /* have we bootstrapped? */

  OBJ_CURRENT_THREAD = 68,

  OBJ_THREADS = 69,
  OBJ_RUN_QUEUE = 70,
  OBJ_SLEEP_QUEUE = 71,

  OBJ_VM_COMPILER = 72, /* version string of the compiler we were built with */

  OBJ_WAITING_CALLBACKS = 73,

  OBJ_SIGNAL_PIPE = 74, /* file descriptor for pipe used to communicate signals
                           only used on unix */
  OBJ_VM_COMPILE_TIME = 75, /* when the binary was built */
  OBJ_VM_VERSION = 76, /* factor version */
  OBJ_VM_GIT_LABEL = 77, /* git label (git describe --all --long) */
};

/* save-image-and-exit discards special objects that are filled in on startup
   anyway, to reduce image size */
#define OBJ_FIRST_SAVE OBJ_STARTUP_QUOT
#define OBJ_LAST_SAVE OBJ_STAGE2

inline static bool save_special_p(cell i) {
  return (i >= OBJ_FIRST_SAVE && i <= OBJ_LAST_SAVE);
}

template <typename Iterator> void object::each_slot(Iterator& iter) {
  cell* start = (cell*)this + 1;
  cell* end = start + slot_count();

  while (start < end) {
    iter(start);
    start++;
  }
}

}
