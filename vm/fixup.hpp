namespace factor {

struct no_fixup {
  static const bool translated_code_block_map = false;

  object* fixup_data(object* obj) { return obj; }

  code_block* fixup_code(code_block* compiled) { return compiled; }

  object* translate_data(const object* obj) { return fixup_data(const_cast<object*>(obj)); }

  code_block* translate_code(const code_block* compiled) {
    return fixup_code(const_cast<code_block*>(compiled));
  }

  cell size(object* obj) { return obj->size(); }

  cell size(code_block* compiled) { return compiled->size(); }
};

}
