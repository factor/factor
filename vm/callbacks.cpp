#include "master.hpp"

namespace factor {

bool return_takes_param_p() {
#if defined(FACTOR_X86) || defined(FACTOR_AMD64)
  return true;
#else
  return false;
#endif
}

callback_heap::callback_heap(cell size, factor_vm* parent) {
  seg = new segment(size, true);
  if (!seg)
    fatal_error("Out of memory in callback_heap constructor", size);
  allocator = new free_list_allocator<code_block>(size, seg->start);
  this->parent = parent;

}

callback_heap::~callback_heap() {
  delete allocator;
  allocator = NULL;
  delete seg;
  seg = NULL;
}

// A fixnum marker survives GC without adding another callback heap root.
// In particular, do not store a template pointer in parameters: callback GC
// visitors intentionally visit only owner.
static bool variadic_callback_p(code_block* stub) {
  return stub->parameters == tag_fixnum(1);
}

VM_C_API bool arm64_variadic_callbacks_supported() {
#ifdef FACTOR_ARM64
  return true;
#else
  return false;
#endif
}

instruction_operand callback_heap::callback_operand(code_block* stub,
                                                    cell index) {
  tagged<array> code_template(parent->special_objects[CALLBACK_STUB]);
  if (variadic_callback_p(stub))
    code_template = tagged<array>(array_nth(code_template.untagged(), 2));
  tagged<byte_array> relocation_template(
      array_nth(code_template.untagged(), 0));

  relocation_entry entry(relocation_template->data<relocation_entry>()[index]);
  return instruction_operand(entry, stub, 0);
}

void callback_heap::store_callback_operand(code_block* stub, cell index,
                                           cell value) {
  instruction_operand op = callback_operand(stub, index);
  op.store_value(value);
}

void callback_heap::update(code_block* stub) {
  word* w = untag<word>(stub->owner);
#ifdef FACTOR_ARM64
  store_callback_operand(stub, 6, w->entry_point);
#else
  store_callback_operand(stub, 1, w->entry_point);
#endif
  stub->flush_icache();
}

// Unlike ordinary code, callback stubs are pinned and are freed explicitly.
// The size-segregated allocator does not merge blocks on free. Mixed ordinary
// and variadic templates can therefore exhaust one size class while most of
// the heap is free. Rebuild the free lists without moving any live stub.
static void coalesce_callback_free_blocks(
    free_list_allocator<code_block>* allocator) {
  allocator->clear_free_list();
  cell scan = allocator->start;
  while (scan < allocator->end) {
    free_heap_block* block = (free_heap_block*)scan;
    cell size = block->size();
    if (block->free_p()) {
      cell next = scan + size;
      while (next < allocator->end) {
        free_heap_block* following = (free_heap_block*)next;
        if (!following->free_p())
          break;
        cell following_size = following->size();
        size += following_size;
        next += following_size;
      }
      block->make_free(size);
      allocator->add_to_free_list(block);
    }
    scan += size;
  }
}

code_block* callback_heap::add(cell owner, cell return_rewind) {
  // Allocates a stub in the MAP_JIT callback heap, memcpy's the template code
  // in and stores its relocations (via update() below).
  jit_writable_scope jit_writable;
  // The first two elements contain relocations and machine code. ARM64's
  // optional third element contains the corresponding variadic template.
  tagged<array> code_template(parent->special_objects[CALLBACK_STUB]);
  bool variadic = false;
#ifdef FACTOR_ARM64
  variadic = return_rewind == (cell)-1;
  if (variadic) {
    if (array_capacity(code_template.untagged()) < 3)
      parent->general_error(ERROR_FFI, false_object, false_object);
    code_template = tagged<array>(array_nth(code_template.untagged(), 2));
  }
#endif
  tagged<byte_array> insns(array_nth(code_template.untagged(), 1));
  cell size = array_capacity(insns.untagged());

  cell bump = align(size + sizeof(code_block), data_alignment);
  code_block* stub = allocator->allot(bump);
  if (!stub) {
    // This writes only free-block headers, under the existing writable scope.
    coalesce_callback_free_blocks(allocator);
    stub = allocator->allot(bump);
  }
  if (!stub) {
    parent->general_error(ERROR_CALLBACK_SPACE_OVERFLOW,
                          false_object,
                          false_object);
  }
  stub->header = bump & ~7;
  stub->owner = owner;
  stub->parameters = variadic ? tag_fixnum(1) : false_object;
  stub->relocation = false_object;

  memcpy((void*)stub->entry_point(), insns->data<void>(), size);

#if defined(FACTOR_ARM64) && defined(WINDOWS)
  uint32_t* instructions = (uint32_t*)stub->entry_point();
  for (cell i = 0; i < size / sizeof(uint32_t); i++) {
    if (instructions[i] == 0xa900bd2e || instructions[i] == 0xa900b92f) {
      instructions[i] = 0xa900ba4f;
    }

    if (i + 4 < size / sizeof(uint32_t) &&
        instructions[i] == 0x910003e9 &&
        instructions[i + 1] == 0xf9001289 &&
        instructions[i + 2] == 0xf940064e &&
        instructions[i + 3] == 0xf9400a4f &&
        instructions[i + 4] == 0xa9bf3fee) {
      instructions[i] = 0xf940064e;
      instructions[i + 1] = 0xf9400a4f;
      instructions[i + 2] = 0xa9bf3fee;
      instructions[i + 3] = 0x910003e9;
      instructions[i + 4] = 0xf9001289;
    }
  }
#endif

  // Store VM pointer in two relocations.
  store_callback_operand(stub, 0, (cell)parent);
#ifdef FACTOR_ARM64
  store_callback_operand(stub, 1, parent->code->safepoint_page);
  store_callback_operand(stub, 2, (cell)&factor::trampoline);
  store_callback_operand(stub, 3, (cell)&factor::trampoline2);
  store_callback_operand(stub, 4, (cell)&factor::inline_cache_miss);
  store_callback_operand(stub, 5, (cell)&parent->dispatch_stats.megamorphic_cache_hits);
#else
  store_callback_operand(stub, 2, (cell)parent);
#endif

  // On x86, the RET instruction takes an argument which depends on
  // the callback's calling convention
  if (return_takes_param_p())
    store_callback_operand(stub, 3, return_rewind);

  update(stub);
  return stub;
}

// Allocates memory (add(), allot_alien())
void factor_vm::primitive_callback() {
  cell return_rewind = to_cell(ctx->pop());
  tagged<word> w(ctx->pop());
  check_tagged(w);

  cell func = callbacks->add(w.value(), return_rewind)->entry_point();
  CODE_TO_FUNCTION_POINTER_CALLBACK(this, func);
  ctx->push(allot_alien(func));
}

void factor_vm::primitive_free_callback() {
  void* entry_point = alien_offset(ctx->pop());
  code_block* stub = (code_block*)entry_point - 1;
  // Writes a free-list header into the MAP_JIT callback heap.
  jit_writable_scope jit_writable;
  callbacks->allocator->free(stub);
}

// Allocates memory
void factor_vm::primitive_callback_room() {
  allocator_room room = callbacks->allocator->as_allocator_room();
  ctx->push(tag<byte_array>(byte_array_from_value(&room)));
}

}
