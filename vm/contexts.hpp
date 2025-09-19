#include <array>
#include <memory>

namespace factor {

// Context object count and identifiers must be kept in sync with:
//   core/kernel/kernel.factor
static const cell context_object_count = 4;

enum context_object {
  OBJ_NAMESTACK,
  OBJ_CATCHSTACK,
  OBJ_CONTEXT,
  OBJ_IN_CALLBACK_P,
};

// When the callstack fills up (e.g by to deep recursion), a callstack
// overflow error is triggered. So before continuing executing on it
// in general_error(), we chop off this many bytes to have some space
// to work with. macOS 64 bit needs more than 8192. See issue #1419.
#if defined(FACTOR_WITH_ADDRESS_SANITIZER)
// AddressSanitizer adds large red zones around stack frames which
// effectively shrink the usable callstack size. Increase the reserved
// slack so GC and error handlers have room to run when the stack is
// close to exhaustion during sanitizer builds.
static const cell stack_reserved = 1048576;
#else
static const cell stack_reserved = 16384;
#endif

struct context {

  // First 5 fields accessed directly by compiler. See basis/vm/vm.factor

  // Factor callstack pointers
  cell callstack_top;
  cell callstack_bottom;

  // current datastack top pointer
  cell datastack;

  // current retain stack top pointer
  cell retainstack;

  // C callstack pointer
  cell callstack_save;

  std::unique_ptr<segment> datastack_seg;
  std::unique_ptr<segment> retainstack_seg;
  std::unique_ptr<segment> callstack_seg;

  // context-specific special objects, accessed by context-object and
  // set-context-object primitives
  std::array<cell, context_object_count> context_objects;

  context(cell ds_size, cell rs_size, cell cs_size);
  ~context();

  void reset_datastack();
  void reset_retainstack();
  void reset_callstack();
  void reset_context_objects();
  void reset();
  void fix_stacks();
  void fill_stack_seg(cell top_ptr, const std::unique_ptr<segment>& seg, cell pattern);
  vm_error_type address_to_error(cell addr);

  cell peek() { return *reinterpret_cast<cell*>(datastack); }

  void replace(cell tagged) { *reinterpret_cast<cell*>(datastack) = tagged; }

  cell pop() {
    cell value = peek();
    datastack -= sizeof(cell);
    return value;
  }

  void push(cell tagged) {
    datastack += sizeof(cell);
    replace(tagged);
  }
};

VM_C_API context* new_context(factor_vm* parent);
VM_C_API void delete_context(factor_vm* parent);
VM_C_API void reset_context(factor_vm* parent);
VM_C_API cell begin_callback(factor_vm* parent, cell quot);
VM_C_API void end_callback(factor_vm* parent);

}
