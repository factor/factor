namespace factor {

// Special object count and identifiers must be kept in sync with:
//   core/kernel/kernel.factor
//   basis/bootstrap/image/image.factor

static const cell special_object_count = 85;

enum special_object {
  OBJ_WALKER_HOOK = 3, // non-local exit hook, used by library only
  OBJ_CALLCC_1,        // used to pass the value in callcc1

  ERROR_HANDLER_QUOT = 5, // quotation called when VM throws an error

  OBJ_CELL_SIZE = 7, // sizeof(cell)
  OBJ_CPU,           // CPU architecture
  OBJ_OS,            // operating system name

  OBJ_ARGS = 10, // command line arguments
  OBJ_STDIN,     // stdin FILE* handle
  OBJ_STDOUT,    // stdout FILE* handle

  OBJ_IMAGE = 13, // image path name
  OBJ_EXECUTABLE, // runtime executable path name

  OBJ_EMBEDDED = 15,  // are we embedded in another app?
  OBJ_EVAL_CALLBACK,  // used when Factor is embedded in a C app
  OBJ_YIELD_CALLBACK, // used when Factor is embedded in a C app
  OBJ_SLEEP_CALLBACK, // used when Factor is embedded in a C app

  OBJ_STARTUP_QUOT = 20, // startup quotation
  OBJ_GLOBAL,            // global namespace
  OBJ_SHUTDOWN_QUOT,     // shutdown quotation

  // Quotation compilation in quotations.cpp
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
  JIT_UNUSED,
  JIT_PUSH_LITERAL,
  JIT_DIP_WORD,
  JIT_DIP,
  JIT_2DIP_WORD,
  JIT_2DIP,
  JIT_3DIP_WORD,
  JIT_3DIP,
  JIT_EXECUTE,
  JIT_DECLARE_WORD,

  // External entry points. These are defined in the files in
  // bootstrap/assembler/
  C_TO_FACTOR_WORD = 43,
  LAZY_JIT_COMPILE_WORD,
  UNWIND_NATIVE_FRAMES_WORD,
  GET_FPU_STATE_WORD,
  SET_FPU_STATE_WORD,
  SIGNAL_HANDLER_WORD,
  LEAF_SIGNAL_HANDLER_WORD,
  WIN_EXCEPTION_HANDLER,

  // Vector used by the sampling profiler to store collected call
  // frames.
  OBJ_SAMPLE_CALLSTACKS = 51,

  // Incremented on every modify-code-heap call; invalidates call(
  // inline caching
  REDEFINITION_COUNTER = 52,

  // Callback stub generation in callbacks.cpp
  CALLBACK_STUB = 53,

  // Polymorphic inline cache generation in inline_cache.cpp
  PIC_LOAD = 54,
  PIC_TAG,
  PIC_TUPLE,
  PIC_CHECK_TAG,
  PIC_CHECK_TUPLE,
  PIC_HIT,
  PIC_MISS_WORD,
  PIC_MISS_TAIL_WORD,

  // Megamorphic cache generation in dispatch.cpp
  MEGA_LOOKUP = 62,
  MEGA_LOOKUP_WORD,
  MEGA_MISS_WORD,

  OBJ_UNDEFINED = 65, // default quotation for undefined words

  OBJ_STDERR = 66, // stderr FILE* handle

  OBJ_STAGE2 = 67, // have we bootstrapped?

  OBJ_CURRENT_THREAD = 68,

  OBJ_THREADS = 69,
  OBJ_RUN_QUEUE = 70,
  OBJ_SLEEP_QUEUE = 71,

  OBJ_VM_COMPILER = 72, // version string of the compiler we were built with

  OBJ_WAITING_CALLBACKS = 73,

  OBJ_SIGNAL_PIPE = 74, // file descriptor for pipe used to communicate signals
                        //  only used on unix
  OBJ_VM_COMPILE_TIME = 75, // when the binary was built
  OBJ_VM_VERSION = 76, // factor version
  OBJ_VM_GIT_LABEL = 77, // git label (git describe --all --long)

  // Canonical truth value. In Factor, 't'
  OBJ_CANONICAL_TRUE = 78,

  // Canonical bignums. These needs to be kept in the image in case
  // some heap objects refer to them.
  OBJ_BIGNUM_ZERO,
  OBJ_BIGNUM_POS_ONE,
  OBJ_BIGNUM_NEG_ONE = 81,
};

// save-image-and-exit discards special objects that are filled in on startup
// anyway, to reduce image size
inline static bool save_special_p(cell i) {
  // Need to fix the order here.
  return (i >= OBJ_STARTUP_QUOT && i <= LEAF_SIGNAL_HANDLER_WORD) ||
      (i >= REDEFINITION_COUNTER && i <= OBJ_UNDEFINED) ||
      i == OBJ_STAGE2 ||
      (i >= OBJ_CANONICAL_TRUE && i <= OBJ_BIGNUM_NEG_ONE);
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
