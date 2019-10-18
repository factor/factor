namespace factor {

struct jit {
  data_root<object> owner;
  growable_byte_array code;
  growable_byte_array relocation;
  growable_array parameters;
  growable_array literals;
  bool computing_offset_p;
  fixnum position;
  cell offset;
  factor_vm* parent;

  jit(cell owner, factor_vm* parent);
  ~jit();

  void compute_position(cell offset);

  void emit_relocation(cell relocation_template);
  void emit(cell code_template);

  // Allocates memory
  void parameter(cell parameter) { parameters.add(parameter); }
  // Allocates memory
  void emit_with_parameter(cell code_template_, cell parameter_);

  // Allocates memory
  void literal(cell literal) { literals.add(literal); }
  // Allocates memory
  void emit_with_literal(cell code_template_, cell literal_);

  // Allocates memory
  void push(cell literal) {
    emit_with_literal(parent->special_objects[JIT_PUSH_LITERAL], literal);
  }

  bool emit_subprimitive(cell word_, bool tail_call_p, bool stack_frame_p);

  fixnum get_position() {
    if (computing_offset_p) {
      // If this is still on, emit() didn't clear it,
      // so the offset was out of bounds
      return -1;
    }
    return position;
  }

  void set_position(fixnum position_) {
    if (computing_offset_p)
      position = position_;
  }

  code_block* to_code_block(code_block_type type, cell frame_size);

private:
  jit(const jit&);
  void operator=(const jit&);
};

}
