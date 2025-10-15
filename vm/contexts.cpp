#include "master.hpp"
#include <cstring>

namespace factor {

namespace {

inline context* context_from_alien_pointer(char* raw_pointer) {
  return static_cast<context*>(static_cast<void*>(raw_pointer));
}

}

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
  fill_stack_seg(datastack, datastack_seg, 0x11111111);
}

void context::reset_retainstack() {
  retainstack = retainstack_seg->start - sizeof(cell);
  fill_stack_seg(retainstack, retainstack_seg, 0x22222222);
}

void context::reset_callstack() {
  callstack_top = callstack_bottom = CALLSTACK_BOTTOM(this);
}

void context::reset_context_objects() {
  memset_cell(context_objects.data(), false_object,
              context_object_count * sizeof(cell));
}

void context::fill_stack_seg(cell top_ptr, const std::unique_ptr<segment>& seg, cell pattern) {
#ifdef FACTOR_DEBUG
  cell clear_start = top_ptr + sizeof(cell);
  cell clear_size = seg->end - clear_start;
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

context::~context() = default;

context* factor_vm::new_context() {
  context* new_context;

  if (unused_contexts.empty()) {
    new_context = new context(datastack_size, retainstack_size, callstack_size);
  } else {
    new_context = unused_contexts.back();
    new_context->reset();
    unused_contexts.pop_back();
  }

  active_contexts.insert(new_context);

  return new_context;
}

// Allocates memory
void factor_vm::init_context(context* target_ctx) {
  target_ctx->context_objects[OBJ_CONTEXT] = allot_alien(reinterpret_cast<cell>(target_ctx));
}

// Allocates memory (init_context(), but not parent->new_context()
VM_C_API context* new_context(factor_vm* parent) {
  context* new_context = parent->new_context();
  parent->init_context(new_context);
  return new_context;
}

void factor_vm::delete_context() {
  unused_contexts.push_back(ctx);
  active_contexts.erase(ctx);

  while (unused_contexts.size() > 10) {
    context* stale_context = unused_contexts.front();
    unused_contexts.pop_front();
    delete stale_context;
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

  context* current_ctx = parent->ctx;
  cell arg1 = current_ctx->pop();
  cell arg2 = current_ctx->pop();
  current_ctx->reset();
  current_ctx->push(arg2);
  current_ctx->push(arg1);
  parent->init_context(current_ctx);
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
  context* other_ctx = context_from_alien_pointer(pinned_alien_offset(ctx->pop()));
  fixnum n = untag_fixnum(ctx->peek());
  ctx->replace(other_ctx->context_objects[n]);
}

// Allocates memory
cell factor_vm::stack_to_array(cell bottom, cell top, vm_error_type error) {
  fixnum depth = (fixnum)(top - bottom + sizeof(cell));

  if (depth < 0) {
    general_error(error, false_object, false_object);
  }
  array* a = allot_uninitialized_array<array>(depth / sizeof(cell));
  const auto count = static_cast<size_t>(depth / sizeof(cell));
  auto* source = reinterpret_cast<const cell*>(bottom);
  std::copy_n(source, count, a->data());
  return tag<array>(a);
}

// Allocates memory
cell factor_vm::datastack_to_array(context* target_ctx) {
  return stack_to_array(target_ctx->datastack_seg->start,
                        target_ctx->datastack,
                        ERROR_DATASTACK_UNDERFLOW);
}

// Allocates memory
void factor_vm::primitive_datastack_for() {
  data_root<alien> alien_ctx(ctx->pop(), this);
  context* other_ctx = context_from_alien_pointer(pinned_alien_offset(alien_ctx.value()));
  cell array = datastack_to_array(other_ctx);
  ctx->push(array);
}

// Allocates memory
cell factor_vm::retainstack_to_array(context* target_ctx) {
  return stack_to_array(target_ctx->retainstack_seg->start,
                        target_ctx->retainstack,
                        ERROR_RETAINSTACK_UNDERFLOW);
}

// Allocates memory
void factor_vm::primitive_retainstack_for() {
  context* other_ctx = context_from_alien_pointer(pinned_alien_offset(ctx->peek()));
  ctx->replace(retainstack_to_array(other_ctx));
}

// returns pointer to top of stack
static cell array_to_stack(array* array, cell bottom) {
  cell depth = array_capacity(array) * sizeof(cell);
  auto* dest = reinterpret_cast<cell*>(bottom);
  std::copy_n(array->data(), static_cast<size_t>(array_capacity(array)), dest);
  return bottom + depth - sizeof(cell);
}

void factor_vm::primitive_set_datastack() {
  array* arr = untag_check<array>(ctx->pop());
  ctx->datastack = array_to_stack(arr, ctx->datastack_seg->start);
}

void factor_vm::primitive_set_retainstack() {
  array* arr = untag_check<array>(ctx->pop());
  ctx->retainstack = array_to_stack(arr, ctx->retainstack_seg->start);
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
    auto compare_count = saved_height - in;
    const cell* stack_begin = reinterpret_cast<cell*>(ctx->datastack_seg->start);
    const cell* stack_end = stack_begin + compare_count;
    const cell* saved_begin = saved_datastack->data();
    if (std::equal(stack_begin, stack_end, saved_begin))
      ctx->push(special_objects[OBJ_CANONICAL_TRUE]);
    else
      ctx->push(false_object);
  }
}

void factor_vm::primitive_load_locals() {
  fixnum count = untag_fixnum(ctx->pop());
  auto* dest = reinterpret_cast<cell*>(ctx->retainstack + sizeof(cell));
  auto* src = reinterpret_cast<cell*>(ctx->datastack - sizeof(cell) * (count - 1));
  std::copy_n(src, static_cast<size_t>(count), dest);
  ctx->datastack -= sizeof(cell) * count;
  ctx->retainstack += sizeof(cell) * count;
}

}
