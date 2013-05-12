namespace factor {

// Context object count and identifiers must be kept in sync with:
//   core/kernel/kernel.factor

static const cell context_object_count = 10;

enum context_object {
  OBJ_NAMESTACK,
  OBJ_CATCHSTACK,
  OBJ_CONTEXT,
  OBJ_IN_CALLBACK_P,
};

static const cell stack_reserved = 1024;

struct context {

  // First 4 fields accessed directly by compiler. See basis/vm/vm.factor

  /* Factor callstack pointers */
  void* callstack_top;
  void* callstack_bottom;

  /* current datastack top pointer */
  cell datastack;

  /* current retain stack top pointer */
  cell retainstack;

  /* C callstack pointer */
  cell callstack_save;

  segment* datastack_seg;
  segment* retainstack_seg;
  segment* callstack_seg;

  /* context-specific special objects, accessed by context-object and
     set-context-object primitives */
  cell context_objects[context_object_count];

  context(cell datastack_size, cell retainstack_size, cell callstack_size);
  ~context();

  void reset_datastack();
  void reset_retainstack();
  void reset_callstack();
  void reset_context_objects();
  void reset();
  void fix_stacks();
  void scrub_stacks(gc_info* info, cell index);

  cell peek() { return *(cell*)datastack; }

  void replace(cell tagged) { *(cell*)datastack = tagged; }

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
VM_C_API void delete_context(factor_vm* parent, context* old_context);
VM_C_API void reset_context(factor_vm* parent, context* ctx);
VM_C_API cell begin_callback(factor_vm* parent, cell quot);
VM_C_API void end_callback(factor_vm* parent);

}
