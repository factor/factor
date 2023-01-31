namespace factor {

struct quotation_jit : public jit {
  data_root<array> elements;
  bool compiling, relocate;

  // Allocates memory
  quotation_jit(cell owner, bool compiling, bool relocate, factor_vm* vm)
      : jit(owner, vm),
        elements(false_object, vm),
        compiling(compiling),
        relocate(relocate) {}

  cell nth(cell index);
  void init_quotation(cell quot);

  bool primitive_call_p(cell i, cell length);
  bool fast_if_p(cell i, cell length);
  bool fast_dip_p(cell i, cell length);
  bool fast_2dip_p(cell i, cell length);
  bool fast_3dip_p(cell i, cell length);
  bool mega_lookup_p(cell i, cell length);
  bool declare_p(cell i, cell length);
  bool special_subprimitive_p(cell obj);

  void emit_mega_cache_lookup(cell methods, fixnum index, cell cache);
  void emit_quotation(cell quot);
  void emit_epilog(bool needed);

  cell word_stack_frame_size(cell obj);
  bool stack_frame_p();
  void iterate_quotation();

  // Allocates memory
  void word_call(cell word) {
    emit_with_literal(parent->special_objects[JIT_WORD_CALL], word);
  }

  // Allocates memory (literal(), emit())
  void word_jump(cell word_) {
    data_root<word> word(word_, parent);
#ifndef FACTOR_64
    literal(tag_fixnum(xt_tail_pic_offset));
#endif
    literal(word.value());
    emit(parent->special_objects[JIT_WORD_JUMP]);
  }
};

VM_C_API cell lazy_jit_compile(cell quot, factor_vm* parent);

}
