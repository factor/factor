// Included after test_vm/check in gc.cpp; exercises the production JIT and
// code-block relocation visitor, without an image or executable test opcodes.
static cell jit_symbol(test_vm& vm, const char* name) {
  byte_array* bytes = vm.allot_byte_array(strlen(name) + 1);
  memcpy(bytes->data<char>(), name, strlen(name) + 1);
  return tag<byte_array>(bytes);
}

static cell jit_template(test_vm& vm, cell pairs, bool third_field) {
  data_root<factor::array> params(vm.allot_array(2 * pairs, false_object), &vm);
  for (cell i = 0; i < pairs; ++i) {
    cell symbol = jit_symbol(vm, "puts");
    vm.set_array_nth(params.untagged(), 2 * i, symbol);
  }
  data_root<byte_array> rels(vm.allot_byte_array((pairs + 1) * sizeof(relocation_entry)), &vm);
  for (cell i = 0; i <= pairs; ++i)
    rels->data<relocation_entry>()[i] = relocation_entry(RT_DLSYM, RC_ABSOLUTE_CELL, (i + 1) * sizeof(cell));
  data_root<byte_array> bytes(vm.allot_byte_array((pairs + 1) * sizeof(cell) + 16), &vm);
  memset(bytes->data<uint8_t>() + (pairs + 1) * sizeof(cell), 0xa5, 16);
  data_root<factor::array> result(vm.allot_array(third_field ? 3 : 2, false_object), &vm);
  vm.set_array_nth(result.untagged(), 0, rels.value());
  vm.set_array_nth(result.untagged(), 1, bytes.value());
  if (third_field)
    vm.set_array_nth(result.untagged(), 2, params.value());
  return result.value();
}

struct jit_parameter_visitor {
  test_vm& vm;
  cell seen = 0;
  void operator()(instruction_operand op) {
    check(op.index == 2 * seen, "JIT relocation visitor skipped/misordered parameters");
    check(op.rel.type() == RT_DLSYM, "JIT relocation type changed");
    cell expected = vm.compute_dlsym_address(untag<factor::array>(op.compiled->parameters), op.index, false);
    check((cell)op.load_value(0) == expected, "JIT relocation resolved the wrong symbol pair");
    ++seen;
  }
};

static void test_jit_template_parameters(bool third_field, cell pairs, bool collect) {
  test_vm vm;
  jit compiler(false_object, &vm);
  data_root<factor::array> first(jit_template(vm, 0, false), &vm);
  data_root<object> first_symbol(jit_symbol(vm, "strlen"), &vm);
  compiler.parameter(first_symbol.value());
  compiler.parameter(false_object);
  compiler.emit(first.value());
  check(compiler.parameters.count == 2, "Old two-field template changed parameters");

  // Root only through emit itself: collection during static-table append must
  // retain the template, relocation bytes, code bytes and symbol objects.
  cell next = jit_template(vm, pairs, third_field);
  compiler.parameter(first_symbol.value());
  compiler.parameter(false_object);
  if (collect) {
    cell available = vm.nursery.free_space();
    check(available > sizeof(byte_array) + data_alignment, "Fixture nursery unexpectedly full");
    vm.allot_byte_array(available - sizeof(byte_array) - data_alignment);
  }
  cell old_backing = compiler.parameters.elements.value();
  cell old_symbol = first_symbol.value();
  compiler.emit(next);
  check(compiler.parameters.count == 4 + 2 * pairs, "Static parameters missing or duplicated");
  check(compiler.code.count == (pairs + 2) * sizeof(cell) + 32, "Template code size changed");
  for (cell i = compiler.code.count - 16; i < compiler.code.count; ++i)
    check(compiler.code.elements->data<uint8_t>()[i] == 0xa5, "Template code bytes lost across GC");
  if (collect) {
    check(old_backing != compiler.parameters.elements.value(), "Static append did not grow");
    check(old_symbol != first_symbol.value(), "Static append did not collect the nursery");
  }

  // The following old-format template must consume its own dynamic pair,
  // after all optional static pairs from the preceding template.
  compiler.parameter(first_symbol.value());
  compiler.parameter(false_object);
  compiler.emit(first.value());
  check(compiler.parameters.count == 6 + 2 * pairs, "Following template parameter index shifted");
  for (cell i = 0; i < pairs; ++i) {
    byte_array* symbol = untag<byte_array>(array_nth(compiler.parameters.elements.untagged(), 4 + 2 * i));
    check(array_capacity(symbol) == 5 && memcmp(symbol->data<char>(), "puts", 5) == 0,
          "Static symbol object corrupted by collection");
    check(array_nth(compiler.parameters.elements.untagged(), 5 + 2 * i) == false_object,
          "Static library parameter changed");
  }
  jit_writable_scope writable;
  code_block* block = compiler.to_code_block(CODE_BLOCK_UNOPTIMIZED, 0);
  vm.initialize_code_block(block);
  jit_parameter_visitor visitor{vm};
  block->each_instruction_operand(visitor);
  check(visitor.seen == 3 + pairs, "Relocation visitor omitted template operands");
  std::cout << "JIT template parameters: fields=" << (third_field ? 3 : 2)
            << " static-pairs=" << pairs << " collect=" << collect << " passed\n";
}

static void test_jit_templates() {
  test_jit_template_parameters(false, 0, false);
  test_jit_template_parameters(true, 0, false);
  test_jit_template_parameters(true, 1, false);
  test_jit_template_parameters(true, 32, true);
}
