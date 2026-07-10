#include "master.hpp"

namespace factor {

context::context(cell ds_size, cell rs_size, cell cs_size)
    : callstack_top(0),
      callstack_bottom(0),
      datastack(0),
      retainstack(0),
      callstack_save(0),
      datastack_seg(new segment(ds_size, false)),
      retainstack_seg(new segment(rs_size, false)),
      callstack_seg(new segment(cs_size, false)),
      valgrind_stack_id(0)
#if defined(FACTOR_ASAN) || defined(FACTOR_TSAN)
      , sanitizer_previous_ctx(NULL)
#endif
#if defined(FACTOR_ASAN)
      , asan_fake_stack(NULL)
#endif
#if defined(FACTOR_TSAN)
      , tsan_fiber(__tsan_create_fiber(0))
#endif
      {
#ifdef FACTOR_HAS_VALGRIND
  valgrind_stack_id = VALGRIND_STACK_REGISTER(
      reinterpret_cast<void*>(callstack_seg->start),
      reinterpret_cast<void*>(callstack_seg->end));
#endif
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
  memset_cell(context_objects, false_object,
              context_object_count * sizeof(cell));
}

void context::fill_stack_seg(cell top_ptr, segment* seg, cell pattern) {
#ifdef FACTOR_DEBUG
  cell clear_start = top_ptr + sizeof(cell);
  cell clear_size = seg->end - clear_start;
  memset_cell((void*)clear_start, pattern, clear_size);
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
#ifdef FACTOR_HAS_VALGRIND
  VALGRIND_STACK_DEREGISTER(valgrind_stack_id);
#endif
#ifdef FACTOR_TSAN
  __tsan_destroy_fiber(tsan_fiber);
#endif
  delete datastack_seg;
  delete retainstack_seg;
  delete callstack_seg;
}

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
void factor_vm::init_context(context* ctx) {
  ctx->context_objects[OBJ_CONTEXT] = allot_alien((cell)ctx);
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

  context* ctx = parent->ctx;
  data_root<object> arg1(ctx->pop(), parent);
  data_root<object> arg2(ctx->pop(), parent);
  ctx->reset();
  parent->init_context(ctx);
  ctx->push(arg2.value());
  ctx->push(arg1.value());
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

#if defined(FACTOR_ASAN) || defined(FACTOR_TSAN)
static FACTOR_NO_SANITIZE_FIBER factor_vm* sanitizer_vm() {
  return current_vm();
}

static FACTOR_NO_SANITIZE_FIBER void sanitizer_switch_to(
    factor_vm* parent, context* source, context* target, int kind) {
  if (source == target)
    return;

#ifdef FACTOR_ASAN
  if (parent->asan_switch_pending) {
    fprintf(stderr,
            "Factor ASan switch %d (%p -> %p) started before switch %d "
            "finished\n",
            kind, (void*)source, (void*)target, parent->asan_switch_kind);
    abort();
  }
  parent->asan_switch_pending = true;
  parent->asan_switch_kind = kind;
  void** fake_stack = source ? &source->asan_fake_stack
                             : &parent->asan_native_fake_stack;
  const void* bottom = target ? reinterpret_cast<void*>(target->callstack_seg->start)
                              : parent->asan_native_stack_bottom;
  size_t size = target ? target->callstack_seg->size
                       : parent->asan_native_stack_size;
  __sanitizer_start_switch_fiber(fake_stack, bottom, size);
#endif
#ifdef FACTOR_TSAN
  void* fiber = target ? target->tsan_fiber : parent->tsan_native_fiber;
  __tsan_switch_to_fiber(fiber, 0);
#endif
}

static FACTOR_NO_SANITIZE_FIBER void sanitizer_finish_switch(
    factor_vm* parent, context* target, bool source_was_native) {
#ifdef FACTOR_ASAN
  if (!parent->asan_switch_pending) {
    fprintf(stderr, "Factor ASan switch finished without a start\n");
    abort();
  }
  void* fake_stack = target ? target->asan_fake_stack
                            : parent->asan_native_fake_stack;
  const void* old_bottom = NULL;
  size_t old_size = 0;
  __sanitizer_finish_switch_fiber(fake_stack, &old_bottom, &old_size);
  parent->asan_switch_pending = false;
  parent->asan_switch_kind = 0;
  if (source_was_native) {
    parent->asan_native_stack_bottom = old_bottom;
    parent->asan_native_stack_size = old_size;
  }
#else
  (void)parent;
#endif
}
#endif

void sanitizer_start_callback() {
#if defined(FACTOR_ASAN) || defined(FACTOR_TSAN)
  factor_vm* parent = sanitizer_vm();
  context* target = parent->spare_ctx;
  target->sanitizer_previous_ctx = parent->ctx;
  sanitizer_switch_to(parent, parent->ctx, target, 1);
#endif
}

void sanitizer_finish_callback() {
#if defined(FACTOR_ASAN) || defined(FACTOR_TSAN)
  factor_vm* parent = sanitizer_vm();
  context* target = parent->ctx;
  context* source = target->sanitizer_previous_ctx;
  if (source != target)
    sanitizer_finish_switch(parent, target, source == NULL);
#endif
}

void sanitizer_start_callback_return() {
#if defined(FACTOR_ASAN) || defined(FACTOR_TSAN)
  factor_vm* parent = sanitizer_vm();
  context* source = parent->ctx;
  sanitizer_switch_to(parent, source, source->sanitizer_previous_ctx, 2);
#endif
}

void sanitizer_finish_callback_return() {
#if defined(FACTOR_ASAN) || defined(FACTOR_TSAN)
  factor_vm* parent = sanitizer_vm();
  context* target = parent->ctx;
  // The source is always a Factor context on callback return. Its bounds are
  // fixed, so only the destination fake stack must be restored here.
  sanitizer_finish_switch(parent, target, false);
#endif
}

void sanitizer_start_context_switch(factor_vm* parent, context* target) {
#if defined(FACTOR_ASAN) || defined(FACTOR_TSAN)
  target->sanitizer_previous_ctx = parent->ctx;
  sanitizer_switch_to(parent, parent->ctx, target, 3);
#else
  (void)parent;
  (void)target;
#endif
}

void sanitizer_finish_context_switch() {
#if defined(FACTOR_ASAN) || defined(FACTOR_TSAN)
  factor_vm* parent = sanitizer_vm();
  context* target = parent->ctx;
  context* source = target->sanitizer_previous_ctx;
  if (source != target)
    sanitizer_finish_switch(parent, target, source == NULL);
#endif
}

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
  context* other_ctx = (context*)pinned_alien_offset(ctx->pop());
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
  memcpy(a + 1, (void*)bottom, depth);
  return tag<array>(a);
}

// Allocates memory
cell factor_vm::datastack_to_array(context* ctx) {
  return stack_to_array(ctx->datastack_seg->start,
                        ctx->datastack,
                        ERROR_DATASTACK_UNDERFLOW);
}

// Allocates memory
void factor_vm::primitive_datastack_for() {
  data_root<alien> alien_ctx(ctx->pop(), this);
  context* other_ctx = (context*)pinned_alien_offset(alien_ctx.value());
  cell array = datastack_to_array(other_ctx);
  ctx->push(array);
}

// Allocates memory
cell factor_vm::retainstack_to_array(context* ctx) {
  return stack_to_array(ctx->retainstack_seg->start,
                        ctx->retainstack,
                        ERROR_RETAINSTACK_UNDERFLOW);
}

// Allocates memory
void factor_vm::primitive_retainstack_for() {
  context* other_ctx = (context*)pinned_alien_offset(ctx->peek());
  ctx->replace(retainstack_to_array(other_ctx));
}

// returns pointer to top of stack
static cell array_to_stack(array* array, cell bottom) {
  cell depth = array_capacity(array) * sizeof(cell);
  memcpy((void*)bottom, array + 1, depth);
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
  memcpy((cell*)(ctx->retainstack + sizeof(cell)),
         (cell*)(ctx->datastack - sizeof(cell) * (count - 1)),
         sizeof(cell) * count);
  ctx->datastack -= sizeof(cell) * count;
  ctx->retainstack += sizeof(cell) * count;
}

}
