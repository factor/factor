#include "../master.hpp"
#include <atomic>
#include <thread>
#ifndef WINDOWS
#include <sys/wait.h>
#endif

using namespace factor;

static void check(bool condition, const char* message) {
  if (!condition) {
    std::cerr << message << std::endl;
    ::exit(1);
  }
}

// No image or Factor code is needed to exercise the collector.
struct test_vm : factor_vm {
  test_vm() : factor_vm(THREADHANDLE()) {
    std::fill(special_objects, special_objects + special_object_count,
              false_object);
    set_data_heap(new data_heap(&nursery, deck_size, deck_size, 16 * deck_size));
    jit_writable_scope writable;
    code = new code_heap(deck_size);
    callbacks = new callback_heap(deck_size, this);
    ctx = new context(deck_size, deck_size, deck_size);
    active_contexts.insert(ctx);
  }

  ~test_vm() { ctx = NULL; }
};

static byte_array* tenured_bytes(test_vm& vm) {
  // Bypass the small-block pools so consecutive allocations are in order.
  const cell size = 1024;
  byte_array* bytes = (byte_array*)vm.data->tenured->allot(size);
  check(bytes != NULL, "tenured allocation failed");
  bytes->initialize(BYTE_ARRAY_TYPE);
  bytes->capacity = tag_fixnum(size - sizeof(byte_array));
  memset(bytes + 1, 0, size - sizeof(byte_array));
  return bytes;
}

static void test_become_alien() {
  test_vm vm;
  data_root<byte_array> base(tenured_bytes(vm), &vm);
  data_root<alien> displaced(vm.allot_alien(base.value(), 7), &vm);
  vm.gc(COLLECT_FULL_OP, 0);
  data_root<byte_array> replacement(vm.allot_byte_array(100), &vm);
  data_root<factor::array> old_objects(vm.allot_array(1, base.value()), &vm);
  data_root<factor::array> new_objects(vm.allot_array(1, replacement.value()), &vm);
  vm.ctx->push(old_objects.value());
  vm.ctx->push(new_objects.value());
  vm.primitive_become();
  check(displaced->base == replacement.value(), "become did not replace alien base");
  check(displaced->address == (cell)replacement->data<uint8_t>() + 7,
        "become left a stale alien address");
  vm.gc(COLLECT_AGING_OP, 0);
  check(displaced->address == (cell)replacement->data<uint8_t>() + 7,
        "card scanning left a stale alien address");
}

static void test_compact_alien() {
  test_vm vm;
  tenured_bytes(vm); // A hole before the live base forces it to move.
  data_root<byte_array> base(tenured_bytes(vm), &vm);
  data_root<alien> displaced(vm.allot_alien(base.value(), 7), &vm);
  vm.gc(COLLECT_FULL_OP, 0);
  cell old_base = base.value();
  vm.gc(COLLECT_COMPACT_OP, 0);
  check(base.value() != old_base, "compaction did not move the test base");
  check(displaced->base == base.value(), "alien base was not forwarded");
  check(displaced->address == (cell)base->data<uint8_t>() + 7,
        "compaction left a stale alien address");
  base->data<uint8_t>()[7] = 99;
  check(*(uint8_t*)vm.alien_offset(displaced.value()) == 99,
        "displaced alien no longer aliases its base");

  vm.gc(COLLECT_GROWING_DATA_HEAP_OP, 0);
  check(displaced->address == (cell)base->data<uint8_t>() + 7,
        "heap growth left a stale alien address");
}

struct failing_fixup : no_fixup {
  cell visits = 0;
  cell fail_at;

  explicit failing_fixup(cell fail_at) : fail_at(fail_at) {}

  object* fixup_data(object* obj) {
    if (++visits == fail_at)
      throw must_start_gc_again();
    return (object*)((cell)obj + 0x1000);
  }
};

#ifdef FACTOR_PPC
static void test_ppc_interrupted_roots() {
  alignas(data_alignment) uint8_t storage[256] = {};
  code_block* block = (code_block*)storage;
  block->header = sizeof(storage);
  gc_info* info = block->block_gc_info();
  info->gc_root_count = 12;
  info->derived_root_count = 0;
  info->return_address_count = 1;
  info->return_addresses()[0] = 4;
  memset(info->gc_info_bitmap(), 0, info->total_bitmap_bytes());
  info->gc_info_bitmap()[1] = 1; // spill slot eight

  for (auto state : {ppc_leaf, ppc_pre, ppc_active, ppc_post,
                     ppc_temporary, ppc_temporary_leaf}) {
    cell frames[64] = {};
    cell frame = (cell)(frames + 4);
    cell continuation_size = 4 * sizeof(cell);
    *(cell*)(frame + PPC_SIGNAL_FRAME_METADATA) = PPC_SIGNAL_FRAME_MARKER | state;
    check(ppc_signal_frame_p(frame, continuation_size),
          "PowerPC signal continuation metadata was not recognized");
    cell extra = state == ppc_temporary ? 32 : 0;
    cell* spills = (cell*)(frame + continuation_size + extra);
    spills[8] = 0x10009;
    frames[4 + 8] = 0x30009; // wrong signal-frame spill address
    slot_visitor<failing_fixup> visitor(NULL, failing_fixup(0));
    call_frame_slot_visitor<failing_fixup> visit_frame(&visitor);
    visit_frame(frame, continuation_size, block, block->address_for_offset(4));
    bool active = state == ppc_active || state == ppc_temporary;
    check(spills[8] == (active ? 0x11009 : 0x10009),
          "PowerPC interrupted root used the wrong frame or disposition");
    check(frames[4 + 8] == 0x30009,
          "PowerPC signal continuation was mistaken for caller spills");
  }
  std::cout << "PowerPC interrupted roots: width=" << sizeof(cell) * 8
            << " all six frame dispositions passed\n";
}
#endif

#ifdef FACTOR_ALPHA
struct alpha_relocated_fixup : failing_fixup {
  code_block* translated;
  explicit alpha_relocated_fixup(code_block* translated)
      : failing_fixup(0), translated(translated) {}
  code_block* translate_code(const code_block*) { return translated; }
};

static void test_alpha_leaf_roots() {
  alignas(data_alignment) uint8_t code_storage[160] = {};
  code_block* block = (code_block*)code_storage;
  block->header = sizeof(code_storage);
  gc_info* info = block->block_gc_info();
  info->gc_root_count = 6;
  info->derived_root_count = 6;
  info->return_address_count = 1;
  info->return_addresses()[0] = 4;
  std::fill(info->base_pointer_map(), info->base_pointer_map() + 6, UINT32_MAX);
  info->base_pointer_map()[5] = 4;
  info->gc_info_bitmap()[0] = 0x10;
  for (cell caller_size : {cell(32), cell(80), cell(160)}) {
    block->set_stack_frame_size(caller_size);
    for (bool synthetic_leaf : {false, true}) {
      cell frame_size = caller_size - (synthetic_leaf ? 16 : 0);
      cell frames[24] = {};
      cell* frame = frames + 4;
      // Linked frames point to the caller's FP, above its spill area.
      // A synthetic leaf has 16 bytes of linkage; an ordinary callee has 32.
      cell* root = frame + (synthetic_leaf ? 2 : 4);
      root[0] = 0x10009; root[1] = 0x10031;
      frame[6] = 0x30009;
      slot_visitor<failing_fixup> visitor(NULL, failing_fixup(0));
      call_frame_slot_visitor<failing_fixup> visit_frame(&visitor);
      visit_frame((cell)frame, frame_size, block, block->address_for_offset(4));
      check(root[0] == 0x11009 && root[1] == 0x11031,
            "Alpha interrupted caller root/derived alias was not forwarded");
      check(frame[6] == 0x30009, "Alpha collector modified an unrelated slot");
    }
  }
  // Compaction can free or overwrite the old owner before visiting roots.
  // Frame layout, like the map, must come from the translated code block.
  block->set_stack_frame_size(48);
  alignas(data_alignment) uint8_t old_storage[160] = {};
  code_block* old_owner = (code_block*)old_storage;
  for (bool freed : {false, true}) {
    old_owner->header = sizeof(old_storage);
    old_owner->set_stack_frame_size(64);
    if (freed) old_owner->header = sizeof(old_storage) | 1;
    for (bool synthetic_leaf : {false, true}) {
      cell frames[24] = {};
      cell* frame = frames + 4;
      cell* root = frame + (synthetic_leaf ? 2 : 4);
      root[0] = 0x10009; root[1] = 0x10031;
      frame[6] = 0x30009;
      slot_visitor<alpha_relocated_fixup> visitor(NULL, alpha_relocated_fixup(block));
      call_frame_slot_visitor<alpha_relocated_fixup> visit_frame(&visitor);
      visit_frame((cell)frame, synthetic_leaf ? 32 : 48, old_owner,
                  old_owner->address_for_offset(4));
      check(root[0] == 0x11009 && root[1] == 0x11031,
            "Alpha relocated caller map used the stale owner's frame layout");
      check(frame[6] == 0x30009,
            "Alpha relocated caller map modified an unrelated slot");
    }
  }
}
#endif

static void test_derived_roots(cell fail_at) {
  alignas(data_alignment) uint8_t storage[128] = {};
  code_block* block = (code_block*)storage;
  block->header = sizeof(storage);
  gc_info* info = block->block_gc_info();
  info->gc_root_count = 4;
  info->derived_root_count = 4;
  info->return_address_count = 1;
  info->return_addresses()[0] = 4;
  std::fill(info->base_pointer_map(), info->base_pointer_map() + 4, UINT32_MAX);
  info->base_pointer_map()[1] = 0;
  info->base_pointer_map()[3] = 2;
  info->gc_info_bitmap()[0] = 0x5; // Base roots in slots 0 and 2.

#if defined(FACTOR_SPARC) || defined(FACTOR_HPPA) || defined(FACTOR_GC_ROOTS_AT_PREDECESSOR_SP)
  // The return address describes roots in the preceding frame on these ABIs.
  cell frame_storage[8] = {0, 0, 0, 0, 0x10009, 0x10031, 0x20009, 0x20002};
  cell* stack = frame_storage + 4;
  cell frame_top = (cell)frame_storage;
  cell frame_size = 4 * sizeof(cell);
#else
  cell stack[] = {0x10009, 0x10031, 0x20009, 0x20002};
  cell frame_top = (cell)stack;
  cell frame_size = sizeof(stack);
#endif
  cell offsets[] = {stack[1] - stack[0], stack[3] - stack[2]};
  slot_visitor<failing_fixup> visitor(NULL, failing_fixup(fail_at));
  call_frame_slot_visitor<failing_fixup> visit_frame(&visitor);
  bool failed = false;
  try {
    visit_frame(frame_top, frame_size, block, block->address_for_offset(4));
  } catch (const must_start_gc_again&) {
    failed = true;
  }
  check(failed == (fail_at != 0), "unexpected collection failure");
  check(stack[1] - stack[0] == offsets[0] && stack[3] - stack[2] == offsets[1],
        "collection failure corrupted derived roots");

  // The higher-generation retry must see pointers, not the temporary offsets.
  visitor.fixup.fail_at = 0;
  visit_frame(frame_top, frame_size, block, block->address_for_offset(4));
  check(stack[1] - stack[0] == offsets[0] && stack[3] - stack[2] == offsets[1],
        "collection retry corrupted derived roots");
}

static void test_tuple_bounds(cell capacity) {
  test_vm vm;
  data_root<tuple_layout> layout((tuple_layout*)vm.allot_array(3, false_object), &vm);
  layout->size = tag_fixnum(capacity);
  cell* boundary = (cell*)(vm.nursery.here + align(factor::tuple_size(layout.untagged()),
                                                 data_alignment));
  *boundary = 0x12345678;
  vm.ctx->push(layout.value());
  vm.primitive_tuple();
  check(*boundary == 0x12345678, "tuple initialization wrote past its allocation");
  factor::tuple* result = untag<factor::tuple>(vm.ctx->pop());
  for (cell i = 0; i < capacity; i++)
    check(result->data()[i] == false_object, "tuple slot was not initialized");
}

static void test_gc_events() {
  test_vm vm;
  for (cell i = 0; i < 3; i++) {
    vm.primitive_enable_gc_events();
    vm.gc(COLLECT_NURSERY_OP, 0);
    vm.primitive_enable_gc_events();
    check(vm.gc_events->empty(), "enabling GC events did not reset recording");
    vm.gc(COLLECT_NURSERY_OP, 0);
    vm.primitive_disable_gc_events();
    check(vm.gc_events == NULL, "GC recording was not disabled");
    check(array_capacity(untag<factor::array>(vm.ctx->pop())) == 1,
          "GC events were not returned");
    vm.primitive_disable_gc_events();
    check(vm.ctx->pop() == false_object, "disabling inactive recording failed");
  }
  // Also exercise VM destruction while recording is enabled, for leak checks.
  vm.primitive_enable_gc_events();
  vm.gc(COLLECT_NURSERY_OP, 0);
}

static void test_code_blocks_retry() {
  test_vm vm;
  const cell block_count = vm.nursery.size / (6 * sizeof(cell)) + 2;
  {
    jit_writable_scope writable;
    delete vm.code;
    vm.code = new code_heap(align(block_count * 48, deck_size) + deck_size);
    for (cell i = 0; i < block_count; i++) {
      code_block* block = vm.code->allocator->allot(48);
      check(block != NULL, "test code heap filled up");
      block->set_type(CODE_BLOCK_UNOPTIMIZED);
      block->owner = block->parameters = block->relocation = false_object;
      memset(block->block_gc_info(), 0, sizeof(gc_info));
    }
    vm.code->initialize_all_blocks_set();
  }

  // Leave enough space for GC's promotion reserve, but not its reserve plus
  // the large result array. Its allocation must collect all the dead code.
  cell size = vm.data->tenured->size - 3 * deck_size;
  byte_array* garbage = (byte_array*)vm.data->tenured->allot(size);
  garbage->initialize(BYTE_ARRAY_TYPE);
  garbage->capacity = tag_fixnum(size - sizeof(byte_array));
  memset_cell(garbage + 1, 0x12345679, size - sizeof(byte_array));
  vm.primitive_code_blocks();
  check(array_capacity(untag<factor::array>(vm.ctx->pop())) == 0,
        "code-blocks did not retry after collecting dead code");

  // The discarded tenured result is still subject to remembered-card scans.
  factor::array* discarded = (factor::array*)vm.data->tenured->first_object();
  check(discarded && discarded->type() == ARRAY_TYPE,
        "missing discarded code-blocks result");
  for (cell i = 0; i < array_capacity(discarded); i++)
    check(discarded->data()[i] == false_object,
          "code-blocks retry left uninitialized pointer slots in tenured space");
  vm.gc(COLLECT_AGING_OP, 0);
}

static void test_card_scan_after_dead_tenured_prefix() {
  test_vm vm;
  tenured_bytes(vm);
  data_root<factor::array> survivor(vm.allot_array(1, false_object), &vm);
  vm.gc(COLLECT_FULL_OP, 0);
  tenured_space* tenured = vm.data->tenured;
  check(tenured->contains_p(survivor.untagged()),
        "full collection did not promote the survivor");
  cell card = ((cell)survivor.untagged() - tenured->start) / card_size;
  check(card > 0, "survivor was not placed after the dead prefix");
  check(tenured->starts.find_object_containing_card(card) == tenured->start,
        "object start lookup walked below the first tenured card");

  data_root<byte_array> young(vm.allot_byte_array(16), &vm);
  young->data<uint8_t>()[0] = 42;
  vm.set_array_nth(survivor.untagged(), 0, young.value());
  vm.gc(COLLECT_NURSERY_OP, 0);
  byte_array* referent = untag<byte_array>(survivor->data()[0]);
  check(referent == young.untagged() && referent->data<uint8_t>()[0] == 42,
        "card scan lost the survivor's young referent");
}

#ifdef __APPLE__
static void test_nano_count_timebase() {
  uint64_t before = clock_gettime_nsec_np(CLOCK_UPTIME_RAW);
  uint64_t nanos = nano_count();
  uint64_t after = clock_gettime_nsec_np(CLOCK_UPTIME_RAW);
  check(nanos + 1000 >= before && nanos <= after + 1000,
        "nano_count does not follow the Mach timebase");
}
#endif

#if defined(FACTOR_AMD64) && !defined(WINDOWS)
static void test_safepoint_page_reach() {
  code_heap code((cell)1 << 31);
  for (cell addr : {code.allocator->start, code.seg->end}) {
    fixnum displacement = (fixnum)code.safepoint_page - (fixnum)addr;
    check(displacement == (int32_t)displacement,
          "safepoint page is out of RIP-relative reach of the code heap");
  }
}
#endif

#ifndef WINDOWS
static FILE* code_heap_image(cell size) {
  FILE* file = tmpfile();
  check(file != NULL, "tmpfile failed");
  std::vector<cell> image(size / sizeof(cell));
  ((free_heap_block*)image.data())->make_free(size);
  check(fwrite(image.data(), 1, size, file) == size, "image write failed");
  rewind(file);
  return file;
}

static void test_image_code_heap_capacity() {
  jit_writable_scope writable;
  vm_parameters p;
  p.code_size = 4 * (cell)getpagesize();
  cell capacity = code_heap(p.code_size).allocator->size;
  image_header h = {};

  h.code_size = h.compressed_code_size = capacity;
  FILE* file = code_heap_image(h.code_size);
  {
    test_vm vm;
    delete vm.code;
    vm.load_code_heap(file, &h, &p);
    check(vm.code->allocator->occupied_space() == capacity,
          "image did not fill the code heap");
  }
  fclose(file);

  h.code_size = h.compressed_code_size = capacity + data_alignment;
  file = code_heap_image(h.code_size);
  FILE* log = tmpfile();
  check(log != NULL, "tmpfile failed");
  pid_t pid = fork();
  check(pid >= 0, "fork failed");
  if (pid == 0) {
    dup2(fileno(log), STDERR_FILENO);
    init_mvm();
    test_vm vm;
    delete vm.code;
    vm.load_code_heap(file, &h, &p);
    _exit(0);
  }
  int status;
  check(waitpid(pid, &status, 0) == pid, "waitpid failed");
  char line[128];
  rewind(log);
  check(fgets(line, sizeof(line), log) &&
            strstr(line, "Code heap too small to fit image"),
        "code heap image larger than the allocator was not rejected");
  fclose(log);
  fclose(file);
}
#endif

static void test_thread_vm_registry() {
  init_mvm();
  const size_t count = 16;
  std::atomic<bool> start(false);
  std::vector<factor_vm*> vms(count);
  std::vector<std::thread> threads;
  for (size_t i = 0; i < count; i++)
    threads.emplace_back([&, i]() {
      while (!start) {}
      vms[i] = new_factor_vm();
    });
  start = true;
  for (std::thread& thread : threads)
    thread.join();
  check(thread_vms.size() == count, "concurrent VM registration lost an entry");
  for (factor_vm* vm : vms) {
    std::fill(vm->special_objects, vm->special_objects + special_object_count,
              false_object);
    delete vm;
  }
  check(thread_vms.empty(), "deleted VMs are still registered to their threads");
}

#ifdef WINDOWS
static void test_windows_exceptions_the_handler_cannot_resume() {
  test_vm vm;
  init_mvm();
  register_vm_with_thread(&vm);
  for (DWORD flags : {(DWORD)EXCEPTION_NONCONTINUABLE, (DWORD)EXCEPTION_UNWINDING,
                      (DWORD)EXCEPTION_EXIT_UNWIND}) {
    EXCEPTION_RECORD record = {};
    record.ExceptionCode = 0xe06d7363;
    record.ExceptionFlags = flags;
    CONTEXT context = {};
    check(exception_handler(&record, NULL, &context, NULL) ==
              ExceptionContinueSearch,
          "Windows handler redirected an exception it cannot resume");
  }
  register_vm_with_thread(NULL);
}
#endif

static void test_stack_frame_size_header() {
  code_block block;
  for (cell frame_size : {(cell)0xFF0, (cell)0x1000, (cell)0x1010,
                          stack_frame_size_max}) {
    if (frame_size > stack_frame_size_max)
      continue;
    block.header = code_block_size_max;
    block.set_stack_frame_size(frame_size);
    check(block.stack_frame_size() == frame_size,
          "code block header truncated the stack frame size");
    check(block.size() == code_block_size_max,
          "stack frame size clobbered the code block size");
  }
}

#if defined(FACTOR_HPPA)
static void test_hppa_callback_frames() {
  test_vm vm;
  vm.datastack_size = vm.retainstack_size = vm.callstack_size = deck_size;
  code_block* block = vm.code->allocator->allot(64);
  check(block != NULL, "HPPA callback code allocation failed");
  block->set_type(CODE_BLOCK_UNOPTIMIZED);
  block->owner = block->parameters = block->relocation = false_object;
  memset(block->block_gc_info(), 0, sizeof(gc_info));
  vm.code->initialize_all_blocks_set();
  cell bottom = vm.ctx->callstack_bottom;
  cell top = bottom - 32;
  *(cell*)top = top + 16;
  *(cell*)(top + 4) = block->address_for_offset(4);
  *(cell*)(top + 16) = bottom;
  *(cell*)(top + 20) = (cell)vm.callbacks->seg->start + 16;
  vm.ctx->callstack_top = top;
  int visits = 0;
  auto visitor = [&](cell frame, cell size, code_block* owner, cell addr) {
    check(frame == top && size == 16 && owner == block &&
              addr == block->address_for_offset(4),
          "HPPA callback chain visited wrong moving frame");
    ++visits;
  };
  vm.iterate_callstack(vm.ctx, visitor);
  check(visits == 1, "HPPA callback native return was not skipped");
  data_root<callstack> saved(vm.allot_callstack(32), &vm);
  memcpy((void*)saved->top(), (void*)top, 32);
  *(cell*)saved->top() = 16;
  *(cell*)(saved->top() + 16) = 16;
  visits = 0;
  auto saved_visitor = [&](cell frame, cell size, code_block* owner, cell addr) {
    check(frame == saved->top() && size == 16 && owner == block &&
              addr == block->address_for_offset(4),
          "HPPA saved callback chain visited wrong frame");
    ++visits;
  };
  vm.iterate_callstack_object(saved.untagged(), saved_visitor);
  check(visits == 1, "HPPA saved callback native return was not skipped");
  vm.begin_callback(false_object);
  check(vm.ctx->callstack_top == top && vm.ctx->callstack_bottom == bottom - 16,
        "HPPA begin-callback lost active frames or retained its native boundary");
  data_root<callstack> captured(vm.capture_callstack(vm.ctx), &vm);
  check(untag_fixnum(captured->length) == 16 &&
            *(cell*)(captured->top() + FRAME_RETURN_ADDRESS) ==
                block->address_for_offset(4),
        "HPPA capture serialized its process-local callback return");
  // Leave no synthetic frame alive while the fixture tears down its VM.
  vm.ctx->callstack_top = vm.ctx->callstack_bottom;
}

struct hppa_saved_image_fixup : no_fixup {
  static const bool translated_code_block_map = true;
  cell offset;
  explicit hppa_saved_image_fixup(cell offset_) : offset(offset_) {}
  code_block* translate_code(const code_block* block) {
    return (code_block*)((cell)block + offset);
  }
};

static void test_hppa_saved_image_frames() {
  test_vm vm;
  code_block* block = vm.code->allocator->allot(64);
  check(block != NULL, "HPPA saved image code allocation failed");
  block->set_type(CODE_BLOCK_UNOPTIMIZED);
  block->owner = block->parameters = block->relocation = false_object;
  memset(block->block_gc_info(), 0, sizeof(gc_info));
  vm.code->initialize_all_blocks_set();
  data_root<callstack> saved(vm.allot_callstack(16), &vm);
  cell current_pc = block->address_for_offset(4);
  cell old_pc = current_pc - vm.code->seg->size;
  check(!vm.code->seg->in_segment_p(old_pc),
        "HPPA saved image fixture did not move the old PC outside the heap");
  *(cell*)saved->top() = 16;
  *(cell*)(saved->top() + FRAME_RETURN_ADDRESS) = old_pc;
  hppa_saved_image_fixup fixup(current_pc - old_pc);
  int visits = 0;
  auto visitor = [&](cell frame, cell size, code_block* owner, cell addr) {
    check(frame == saved->top() && size == 16 && owner == block &&
              addr == current_pc,
          "HPPA saved image frame was not translated before heap lookup");
    ++visits;
  };
  vm.iterate_callstack_object(saved.untagged(), visitor, fixup);
  check(visits == 1, "HPPA saved image frame was skipped");
}

static void test_hppa_optimizer_roots() {
  alignas(data_alignment) uint8_t code_storage[160] = {};
  code_block* block = (code_block*)code_storage;
  block->header = sizeof(code_storage);
  gc_info* info = block->block_gc_info();
  info->gc_root_count = 8;
  info->derived_root_count = 8;
  info->return_address_count = 1;
  info->return_addresses()[0] = 4;
  std::fill(info->base_pointer_map(), info->base_pointer_map() + 8, UINT32_MAX);
  info->base_pointer_map()[5] = 4;
  info->base_pointer_map()[7] = 6;
  info->gc_info_bitmap()[0] = 0x50;
  for (cell frame_size : {cell(32), cell(80), cell(160)}) {
    cell frames[64] = {};
    cell* caller = frames + frame_size / sizeof(cell);
    frames[0] = (cell)caller;
    frames[1] = block->address_for_offset(4);
    for (int i = 4; i != 8; ++i) frames[i] = 0x30009 + 0x100 * i;
    caller[4] = 0x10009; caller[5] = 0x10031;
    caller[6] = 0x20009; caller[7] = 0x20002;
    slot_visitor<failing_fixup> visitor(NULL, failing_fixup(0));
    call_frame_slot_visitor<failing_fixup> visit_frame(&visitor);
    visit_frame((cell)frames, frame_size, block, block->address_for_offset(4));
    check(caller[4] == 0x11009 && caller[5] == 0x11031 &&
              caller[6] == 0x21009 && caller[7] == 0x21002,
          "HPPA caller optimizer spills/derived roots were not forwarded");
    for (int i = 4; i != 8; ++i)
      check(frames[i] == cell(0x30009 + 0x100 * i),
            "HPPA GC map visited child locals instead of caller roots");
  }
}
static void test_hppa_sampled_leaf_roots() {
  test_vm vm;
  code_block* caller = vm.code->allocator->allot(160);
  code_block* leaf = vm.code->allocator->allot(64);
  for (code_block* block : {caller, leaf}) {
    block->set_type(CODE_BLOCK_UNOPTIMIZED);
    block->owner = block->parameters = block->relocation = false_object;
    memset(block->block_gc_info(), 0, sizeof(gc_info));
  }
  gc_info* info = caller->block_gc_info();
  info->gc_root_count = 6;
  info->derived_root_count = 6;
  info->return_address_count = 1;
  info->return_addresses()[0] = 4;
  std::fill(info->base_pointer_map(), info->base_pointer_map() + 6, UINT32_MAX);
  info->base_pointer_map()[5] = 4;
  info->gc_info_bitmap()[0] = 0x10;
  vm.code->initialize_all_blocks_set();
  word* handler = vm.allot<word>(sizeof(word));
  memset((char*)handler + sizeof(object), 0, sizeof(word) - sizeof(object));
  handler->subprimitive = tag_fixnum(0);
  handler->entry_point = leaf->entry_point();
  vm.special_objects[LEAF_SIGNAL_HANDLER_WORD] = tag<word>(handler);
  data_root<byte_array> base(vm.allot_byte_array(100), &vm);
  cell original_sp = vm.ctx->callstack_bottom - 64;
  *(cell*)original_sp = vm.ctx->callstack_bottom;
  *(cell*)(original_sp + FRAME_RETURN_ADDRESS) = vm.callbacks->seg->start + 16;
  cell* roots = (cell*)original_sp;
  roots[4] = base.value();
  roots[5] = (cell)base->data<uint8_t>() + 7;
  cell old_base = base.value();
  cell sp = original_sp, pc = leaf->entry_point();
  vm.dispatch_resumable_signal(&sp, &pc, pc);
  check(*(cell*)sp == sp + 16 && *(cell*)(sp + 16) == original_sp,
        "HPPA sampled entry omitted the caller's synthetic frame");
  // The leaf-handler template saves interrupted r2 in this second header.
  *(cell*)(sp + 20) = caller->address_for_offset(4);
  vm.ctx->callstack_top = sp;
  vm.gc(COLLECT_NURSERY_OP, 0);
  check(base.value() != old_base && roots[4] == base.value(),
        "HPPA sampled entry did not forward its caller's live spill");
  check(roots[5] == (cell)base->data<uint8_t>() + 7,
        "HPPA sampled entry did not forward its derived alias");
  vm.ctx->callstack_top = vm.ctx->callstack_bottom;
}

static void test_hppa_relocations() {
  test_hppa_callback_frames();
  test_hppa_saved_image_frames();
  test_hppa_optimizer_roots();
  test_hppa_sampled_leaf_roots();
  for (int32_t lhs : {INT32_MIN, -1001, -1, 0, 1, 1001, INT32_MAX}) {
    for (int32_t rhs : {-100, -3, -1, 1, 3, 100}) {
      const int64_t quotient = int64_t(lhs) / rhs;
      const int64_t remainder = int64_t(lhs) % rhs;
      check(hppa_divide_i32(lhs, rhs) == int32_t(quotient),
            "HPPA native integer divide boundary failed");
      check(hppa_remainder_i32(lhs, rhs) == int32_t(remainder),
            "HPPA native integer remainder boundary failed");
    }
  }
  struct {
    code_block block;
    uint32_t instructions[4];
  } buffer;
  buffer.instructions[0] = 0x22c00000;
  buffer.instructions[1] = 0x36d60000;
  buffer.instructions[2] = 0xe6c02000;
  buffer.instructions[3] = 0x37e23ffb;
  instruction_operand address(
      relocation_entry(RT_UNTAGGED, RC_NATIVE_0, 8), &buffer.block, 0);
  const cell return_address = buffer.block.entry_point() + 16;
  for (uint32_t value : {0u, 42u, 0x12345678u, 0x7fffffffu,
                         0x80000000u, 0xffffffffu}) {
    address.store_value(fixnum(value));
    check(cell(address.load_value(address.pointer)) == cell(value),
          "HPPA relocated address failed to round trip");
    check(cell(get_call_target(return_address)) == cell(value),
          "HPPA call target disagrees with relocated address");
    set_call_target(return_address, cell(value ^ 0x12345678u));
    check(cell(get_call_target(return_address)) == cell(value ^ 0x12345678u),
          "HPPA call target patch failed");
    check(!tail_call_site_p(return_address), "HPPA call mistaken for tail call");
  }
  buffer.instructions[2] = 0xeac0c000;
  buffer.instructions[3] = 0x08000240;
  check(tail_call_site_p(return_address), "HPPA tail call mistaken for call");
  instruction_operand immediate(
      relocation_entry(RT_UNTAGGED, RC_NATIVE_1, 8), &buffer.block, 0);
  for (fixnum value : {-8192, -1, 0, 1, 8191}) {
    immediate.store_value(value);
    check(immediate.load_value(immediate.pointer) == value,
          "HPPA signed instruction immediate failed to round trip");
    check((buffer.instructions[1] & 0xffffc000u) == 0x36d60000u,
          "HPPA immediate patch corrupted opcode/register fields");
  }
}
#endif

static void test_arm64_relocations() {
  struct {
    code_block block;
    uint32_t instruction;
  } buffer;
  buffer.instruction = 0xf100001f; // CMP X0, #0
  instruction_operand op(
      relocation_entry(RT_UNTAGGED, RC_ABSOLUTE_ARM_CMP, 4), &buffer.block, 0);
  for (fixnum value : {0, 2047, 2048, 4095}) {
    op.store_value(value);
    check(op.load_value(op.pointer) == value,
          "ARM64 CMP immediate was sign-extended");
  }
  buffer.instruction = 0xf8400000; // LDUR X0, [X0]
  op.rel = relocation_entry(RT_UNTAGGED, RC_ABSOLUTE_ARM_LDUR, 4);
  for (fixnum value : {-256, -1, 0, 255}) {
    op.store_value(value);
    check(op.load_value(op.pointer) == value,
          "ARM64 LDUR immediate lost its sign");
  }
  buffer.instruction = 0x54000000; // B.EQ
  op.rel = relocation_entry(RT_HERE, RC_RELATIVE_ARM_B_COND_LDR, 4);
  for (fixnum offset : {-0x100000, -4, 0, 0xffffc}) {
    cell target = op.pointer - 4 + offset;
    op.store_value(target);
    check((cell)op.load_value(op.pointer) == target,
          "ARM64 conditional branch boundary did not round trip");
  }
}

#if defined(FACTOR_RISCV32)
static void test_riscv32_cell_relocation() {
  struct {
    code_block block;
    uint32_t code[2];
    uint32_t guard[6];
  } buffer = {};
  buffer.code[0] = 0x537;
  buffer.code[1] = 0x50513;
  std::fill(buffer.guard, buffer.guard + 6, 0xdeadbeef);
  instruction_operand op(
      relocation_entry(RT_UNTAGGED, RC_ABSOLUTE_RISCV_LI, 8), &buffer.block, 0);
  for (cell value : {cell(0), cell(2048), cell(0x7ffff800),
                    cell(0x80000000), cell(0xffffffff)}) {
    op.store_value(fixnum(value));
    check(cell(op.load_value(0)) == value,
          "RV32 literal relocation did not round trip a cell");
    for (uint32_t guard : buffer.guard)
      check(guard == 0xdeadbeef, "RV32 literal relocation overwrote its 8-byte stub");
  }
  op.rel = relocation_entry(RT_HERE, RC_RELATIVE_RISCV, 8);
  buffer.code[0] = 0x297;
  buffer.code[1] = 0x280e7;
  for (cell offset : {cell(0), cell(-4), cell(2048), cell(0x7ffff800),
                     cell(0x80000000), cell(0xffffffff)}) {
    cell target = buffer.block.entry_point() + offset;
    op.store_value(fixnum(target));
    check(cell(op.load_value(op.pointer)) == target,
          "RV32 AUIPC relocation did not wrap its 32-bit displacement");
  }
}
#endif

#if defined(FACTOR_MIPS)
static void test_mips_cell_relocation_and_calls() {
#ifdef FACTOR_MIPS64
  uint32_t code[] = {0x34190000, 0x0019cc38, 0x37390000, 0x0019cc38,
      0x37390000, 0x0019cc38, 0x37390000, 0x0320f809, 0, 0xdeadbeef};
#else
  uint32_t code[] = {0x3c190000, 0x37390000, 0x0320f809, 0, 0xdeadbeef};
#endif
  instruction_operand op(relocation_entry(RT_LITERAL, (relocation_class)14,
      MIPS_LITERAL_BYTES), (code_block*)((cell)code - sizeof(code_block)), 0);
  for (cell value : {cell(0), cell(1), cell(-1), cell(1) << (WORD_SIZE - 1)}) {
    op.store_value(value);
    check(cell(op.load_value(0)) == value, "MIPS instruction operand lost literal bits");
    check(code[MIPS_CALL_BYTES / 4] == 0xdeadbeef, "MIPS relocation overwrote its template");
    const cell end = (cell)code + MIPS_CALL_BYTES;
    check((cell)get_call_target(end) == value, "MIPS call target decoder disagrees with relocation");
    check(!tail_call_site_p(end), "MIPS JALR misidentified as tail call");
    set_call_target(end, value ^ TAG_MASK);
    check((cell)get_call_target(end) == (value ^ TAG_MASK), "MIPS call target patch failed");
    code[MIPS_LITERAL_BYTES / 4] = 0x03200008;
    check(tail_call_site_p(end), "MIPS JR tail call misidentified");
    code[MIPS_LITERAL_BYTES / 4] = 0x0320f809;
  }
}
#endif

#include "jit_templates.hpp"

int main(int argc, char** argv) {
#ifdef FACTOR_PPC
  if (argc == 1 || strcmp(argv[1], "ppc-interrupted-roots") == 0)
    test_ppc_interrupted_roots();
#endif
#ifdef FACTOR_ALPHA
  if (argc == 1 || strcmp(argv[1], "alpha-leaf-roots") == 0)
    test_alpha_leaf_roots();
#endif
  if (argc == 1 || strcmp(argv[1], "jit-templates") == 0)
    test_jit_templates();
#if defined(FACTOR_MIPS)
  test_mips_cell_relocation_and_calls();
#endif

#if defined(FACTOR_HPPA)
  if (argc > 1 && strcmp(argv[1], "hppa-sampled-leaf-roots") == 0)
    test_hppa_sampled_leaf_roots();
  if (argc == 1 || strcmp(argv[1], "hppa-relocations") == 0)
    test_hppa_relocations();
#endif
  if (argc == 1 || strcmp(argv[1], "arm64-relocations") == 0)
    test_arm64_relocations();
  if (argc == 1 || strcmp(argv[1], "stack-frame-size") == 0)
    test_stack_frame_size_header();
#if defined(FACTOR_RISCV32)
  if (argc == 1 || strcmp(argv[1], "riscv32-relocations") == 0)
    test_riscv32_cell_relocation();
#endif
  if (argc == 1 || strcmp(argv[1], "alien") == 0)
    test_compact_alien();
  if (argc == 1 || strcmp(argv[1], "become") == 0)
    test_become_alien();
  if (argc == 1 || strcmp(argv[1], "derived") == 0) {
    test_derived_roots(0);
    test_derived_roots(1);
    test_derived_roots(2);
  }
  if (argc == 1 || strcmp(argv[1], "tuple") == 0) {
    test_tuple_bounds(0);
    test_tuple_bounds(1);
    test_tuple_bounds(2);
    test_tuple_bounds(3);
  }
  if (argc == 1 || strcmp(argv[1], "events") == 0)
    test_gc_events();
  if (argc == 1 || strcmp(argv[1], "code-blocks") == 0)
    test_code_blocks_retry();
  if (argc == 1 || strcmp(argv[1], "card-scan") == 0)
    test_card_scan_after_dead_tenured_prefix();
  if (argc == 1 || strcmp(argv[1], "thread-vms") == 0)
    test_thread_vm_registry();
#if defined(FACTOR_AMD64) && !defined(WINDOWS)
  if (argc == 1 || strcmp(argv[1], "safepoint-reach") == 0)
    test_safepoint_page_reach();
#endif
#ifndef WINDOWS
  if (argc == 1 || strcmp(argv[1], "image-code-heap") == 0)
    test_image_code_heap_capacity();
#endif
#ifdef WINDOWS
  if (argc == 1 || strcmp(argv[1], "windows-exceptions") == 0)
    test_windows_exceptions_the_handler_cannot_resume();
#endif
#ifdef __APPLE__
  if (argc == 1 || strcmp(argv[1], "nano-count") == 0)
    test_nano_count_timebase();
#endif
  std::cout << "GC tests passed" << std::endl;
}
