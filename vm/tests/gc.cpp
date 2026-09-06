#include "../master.hpp"

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

  cell stack[] = {0x10009, 0x10031, 0x20009, 0x20002};
  cell offsets[] = {stack[1] - stack[0], stack[3] - stack[2]};
  slot_visitor<failing_fixup> visitor(NULL, failing_fixup(fail_at));
  call_frame_slot_visitor<failing_fixup> visit_frame(&visitor);
  bool failed = false;
  try {
    visit_frame((cell)stack, sizeof(stack), block, block->address_for_offset(4));
  } catch (const must_start_gc_again&) {
    failed = true;
  }
  check(failed == (fail_at != 0), "unexpected collection failure");
  check(stack[1] - stack[0] == offsets[0] && stack[3] - stack[2] == offsets[1],
        "collection failure corrupted derived roots");

  // The higher-generation retry must see pointers, not the temporary offsets.
  visitor.fixup.fail_at = 0;
  visit_frame((cell)stack, sizeof(stack), block, block->address_for_offset(4));
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

int main(int argc, char** argv) {
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
  std::cout << "GC tests passed" << std::endl;
}
