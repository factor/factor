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

int main(int argc, char** argv) {
  if (argc == 1 || strcmp(argv[1], "alien") == 0)
    test_compact_alien();
  if (argc == 1 || strcmp(argv[1], "become") == 0)
    test_become_alien();
  std::cout << "GC tests passed" << std::endl;
}
