#include "master.hpp"

namespace factor {

context::context(cell ds_size, cell rs_size, cell cs_size)
    : callstack_top(0),
      callstack_bottom(0),
      datastack(0),
      retainstack(0),
      callstack_save(0),
      datastack_seg(std::make_unique<segment>(ds_size, false)),
      retainstack_seg(std::make_unique<segment>(rs_size, false)),
      callstack_seg(std::make_unique<segment>(cs_size, false)) {
  reset();
}

void context::reset_datastack() {
  datastack = datastack_seg->start - sizeof(cell);
  fill_stack_seg(datastack, datastack_seg.get(), 0x11111111);
}

void context::reset_retainstack() {
  retainstack = retainstack_seg->start - sizeof(cell);
  fill_stack_seg(retainstack, retainstack_seg.get(), 0x22222222);
}

void context::reset_callstack() {
  callstack_top = callstack_bottom = CALLSTACK_BOTTOM(this);
}

void context::reset_context_objects() {
  memset_cell(context_objects, false_object,
              context_object_count * sizeof(cell));
}

void context::fill_stack_seg(cell top_ptr, segment* seg, cell pattern) {
#ifdef FACTOR_DEBUG
  cell clear_start = top_ptr + sizeof(cell);
  
  // Ensure we don't go past the end or have a negative size
  if (clear_start >= seg->end) {
    return; // Nothing to clear
  }
  
  cell clear_size = seg->end - clear_start;
  
  // Additional sanity check
  if (clear_size > seg->size) {
    fatal_error("Invalid clear size in fill_stack_seg", clear_size);
  }
  
  memset_cell(reinterpret_cast<void*>(clear_start), pattern, clear_size);
#else
  (void)top_ptr;
  (void)seg;
  (void)pattern;
#endif
}

vm_error_type context::address_to_error(cell addr) {
  if (datastack_seg->underflow_p(addr))
    return ERROR_DATASTACK_UNDERFLOW;
  if (datastack_seg->overflow_p(addr))
    return ERROR_DATASTACK_OVERFLOW;
  if (retainstack_seg->underflow_p(addr))
    return ERROR_RETAINSTACK_UNDERFLOW;
  if (retainstack_seg->overflow_p(addr))
    return ERROR_RETAINSTACK_OVERFLOW;
  // These are flipped because the callstack grows downwards.
  if (callstack_seg->underflow_p(addr))
    return ERROR_CALLSTACK_OVERFLOW;
  if (callstack_seg->overflow_p(addr))
    return ERROR_CALLSTACK_UNDERFLOW;
  return ERROR_MEMORY;
}

void context::reset() {
  reset_datastack();
  reset_retainstack();
  reset_callstack();
  reset_context_objects();
}

void context::fix_stacks() {
  if (datastack + sizeof(cell) < datastack_seg->start ||
      datastack + stack_reserved >= datastack_seg->end)
    reset_datastack();

  if (retainstack + sizeof(cell) < retainstack_seg->start ||
      retainstack + stack_reserved >= retainstack_seg->end)
    reset_retainstack();
}

context::~context() {
  // unique_ptr automatically handles deletion
}

context::context(context&& other) noexcept
    : callstack_top(other.callstack_top),
      callstack_bottom(other.callstack_bottom),
      datastack(other.datastack),
      retainstack(other.retainstack),
      datastack_seg(std::move(other.datastack_seg)),
      retainstack_seg(std::move(other.retainstack_seg)),
      callstack_seg(std::move(other.callstack_seg)),
      context_objects() {
  std::move(std::begin(other.context_objects), std::end(other.context_objects),
            std::begin(context_objects));
  other.datastack = 0;
  other.retainstack = 0;
  other.callstack_top = 0;
  other.callstack_bottom = 0;
}

context& context::operator=(context&& other) noexcept {
  if (this != &other) {
    swap(other);
  }
  return *this;
}

void context::swap(context& other) noexcept {
  using std::swap;
  swap(datastack, other.datastack);
  swap(retainstack, other.retainstack);
  swap(callstack_top, other.callstack_top);
  swap(callstack_bottom, other.callstack_bottom);
  swap(datastack_seg, other.datastack_seg);
  swap(retainstack_seg, other.retainstack_seg);
  swap(callstack_seg, other.callstack_seg);
  swap(context_objects, other.context_objects);
}

context* factor_vm::new_context() {
  std::shared_ptr<context> ctx_ptr;

  if (unused_contexts.empty()) {
    ctx_ptr = std::make_shared<context>(datastack_size, retainstack_size, callstack_size);
  } else {
    ctx_ptr = std::move(unused_contexts.back());
    unused_contexts.pop_back();
    ctx_ptr->reset();
  }

  active_contexts.insert(ctx_ptr);

  return ctx_ptr.get();
}

// Allocates memory
void factor_vm::init_context(context* ctx_) {
  ctx_->context_objects[OBJ_CONTEXT] = allot_alien(reinterpret_cast<cell>(ctx_));
}

// Allocates memory (init_context(), but not parent->new_context()
VM_C_API context* new_context(factor_vm* parent) {
  context* new_context = parent->new_context();
  parent->init_context(new_context);
  return new_context;
}

void factor_vm::delete_context() {
  // Find the shared_ptr for this context
  std::shared_ptr<context> ctx_ptr;
  for (auto it = active_contexts.begin(); it != active_contexts.end(); ++it) {
    if (it->get() == ctx) {
      ctx_ptr = *it;
      active_contexts.erase(it);
      break;
    }
  }
  
  if (ctx_ptr) {
    unused_contexts.push_back(std::move(ctx_ptr));
    
    while (unused_contexts.size() > 10) {
      unused_contexts.pop_front();
    }
  }
}

VM_C_API void delete_context(factor_vm* parent) {
  parent->delete_context();
}

// Allocates memory (init_context())
VM_C_API void reset_context(factor_vm* parent) {

  // The function is used by (start-context-and-delete) which expects
  // the top two datastack items to be preserved after the context has
  // been resetted.

  context* ctx = parent->ctx;
  cell arg1 = ctx->pop();
  cell arg2 = ctx->pop();
  ctx->reset();
  ctx->push(arg2);
  ctx->push(arg1);
  parent->init_context(ctx);
}

// Allocates memory
cell factor_vm::begin_callback(cell quot_) {
  data_root<object> quot(quot_, this);

  ctx->reset();
  spare_ctx = new_context();
  callback_ids.push_back(callback_id++);

  init_context(ctx);

  return quot.value();
}

// Allocates memory
cell begin_callback(factor_vm* parent, cell quot) {
  return parent->begin_callback(quot);
}

void factor_vm::end_callback() {
  callback_ids.pop_back();
  delete_context();
}

void end_callback(factor_vm* parent) { parent->end_callback(); }

void factor_vm::primitive_current_callback() {
  ctx->push(tag_fixnum(callback_ids.back()));
}

void factor_vm::primitive_context_object() {
  fixnum n = untag_fixnum(ctx->peek());
  ctx->replace(ctx->context_objects[n]);
}

void factor_vm::primitive_set_context_object() {
  fixnum n = untag_fixnum(ctx->pop());
  cell value = ctx->pop();
  ctx->context_objects[n] = value;
}

void factor_vm::primitive_context_object_for() {
  void* ptr = pinned_alien_offset(ctx->pop());
  context* other_ctx = static_cast<context*>(__builtin_assume_aligned(ptr, alignof(context)));
  fixnum n = untag_fixnum(ctx->peek());
  ctx->replace(other_ctx->context_objects[n]);
}

// Allocates memory
cell factor_vm::stack_to_array(cell bottom, cell top, vm_error_type error) {
  fixnum depth = static_cast<fixnum>(top - bottom + sizeof(cell));

  if (depth < 0) {
    general_error(error, false_object, false_object);
  }
  
  // Sanity check - stacks shouldn't be enormous
  const cell MAX_STACK_SIZE = 1024 * 1024 * 16; // 16MB max
  if (static_cast<cell>(depth) > MAX_STACK_SIZE) {
    general_error(error, false_object, false_object);
  }
  
  array* a = allot_uninitialized_array<array>(depth / sizeof(cell));
  memcpy(a + 1, reinterpret_cast<void*>(bottom), depth);
  return tag<array>(a);
}

// Allocates memory
cell factor_vm::datastack_to_array(context* ctx_) {
  return stack_to_array(ctx_->datastack_seg->start,
                        ctx_->datastack,
                        ERROR_DATASTACK_UNDERFLOW);
}

// Allocates memory
void factor_vm::primitive_datastack_for() {
  data_root<alien> alien_ctx(ctx->pop(), this);
  void* ptr = pinned_alien_offset(alien_ctx.value());
  context* other_ctx = static_cast<context*>(__builtin_assume_aligned(ptr, alignof(context)));
  cell array = datastack_to_array(other_ctx);
  ctx->push(array);
}

// Allocates memory
cell factor_vm::retainstack_to_array(context* ctx_) {
  return stack_to_array(ctx_->retainstack_seg->start,
                        ctx_->retainstack,
                        ERROR_RETAINSTACK_UNDERFLOW);
}

// Allocates memory
void factor_vm::primitive_retainstack_for() {
  void* ptr = pinned_alien_offset(ctx->peek());
  context* other_ctx = static_cast<context*>(__builtin_assume_aligned(ptr, alignof(context)));
  ctx->replace(retainstack_to_array(other_ctx));
}

// returns pointer to top of stack
static cell array_to_stack(array* array, cell bottom, segment* stack_seg) {
  cell depth = array_capacity(array) * sizeof(cell);
  
  // Check if the array will fit in the stack segment
  if (depth > static_cast<cell>(stack_seg->end - bottom)) {
    fatal_error("Stack overflow: array too large for stack segment", depth);
  }
  
  memcpy(reinterpret_cast<void*>(bottom), array + 1, depth);
  return bottom + depth - sizeof(cell);
}

void factor_vm::primitive_set_datastack() {
  array* arr = untag_check<array>(ctx->pop());
  ctx->datastack = array_to_stack(arr, ctx->datastack_seg->start, ctx->datastack_seg.get());
}

void factor_vm::primitive_set_retainstack() {
  array* arr = untag_check<array>(ctx->pop());
  ctx->retainstack = array_to_stack(arr, ctx->retainstack_seg->start, ctx->retainstack_seg.get());
}

// Used to implement call(
void factor_vm::primitive_check_datastack() {
  fixnum out = to_fixnum(ctx->pop());
  fixnum in = to_fixnum(ctx->pop());
  fixnum height = out - in;
  array* saved_datastack = untag_check<array>(ctx->pop());
  fixnum saved_height = array_capacity(saved_datastack);
  fixnum current_height =
      (ctx->datastack - ctx->datastack_seg->start + sizeof(cell)) /
      sizeof(cell);
  if (current_height - height != saved_height)
    ctx->push(false_object);
  else {
    cell* ds_bot = (cell*)ctx->datastack_seg->start;
    for (fixnum i = 0; i < saved_height - in; i++) {
      if (ds_bot[i] != array_nth(saved_datastack, i)) {
        ctx->push(false_object);
        return;
      }
    }
    ctx->push(special_objects[OBJ_CANONICAL_TRUE]);
  }
}

void factor_vm::primitive_load_locals() {
  fixnum count = untag_fixnum(ctx->pop());
  
  // Bounds checking
  if (count < 0) {
    general_error(ERROR_DATASTACK_UNDERFLOW, false_object, false_object);
  }
  
  cell bytes_to_copy = sizeof(cell) * count;
  
  // Check if we have enough data on the datastack
  if (ctx->datastack - bytes_to_copy + sizeof(cell) < ctx->datastack_seg->start) {
    general_error(ERROR_DATASTACK_UNDERFLOW, false_object, false_object);
  }
  
  // Check if we have enough room on the retainstack
  if (ctx->retainstack + bytes_to_copy > ctx->retainstack_seg->end - stack_reserved) {
    general_error(ERROR_RETAINSTACK_OVERFLOW, false_object, false_object);
  }
  
  memcpy(reinterpret_cast<cell*>(ctx->retainstack + sizeof(cell)),
         reinterpret_cast<cell*>(ctx->datastack - sizeof(cell) * (count - 1)),
         bytes_to_copy);
  ctx->datastack -= bytes_to_copy;
  ctx->retainstack += bytes_to_copy;
}

}
