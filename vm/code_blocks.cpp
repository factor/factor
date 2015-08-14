#include "master.hpp"

namespace factor {

cell code_block::owner_quot() const {
  tagged<object> executing(owner);
  if (!optimized_p() && executing->type() == WORD_TYPE)
    executing = executing.as<word>()->def;
  return executing.value();
}

/* If the code block is an unoptimized quotation, we can calculate the
   scan offset. In all other cases -1 is returned. */
cell code_block::scan(factor_vm* vm, cell addr) const {
  if (type() != code_block_unoptimized) {
    return tag_fixnum(-1);
  }

  tagged<object> obj(owner);
  if (obj.type_p(WORD_TYPE))
    obj = obj.as<word>()->def;
  if (!obj.type_p(QUOTATION_TYPE))
    return tag_fixnum(-1);

  cell ofs = offset(addr);
  return tag_fixnum(vm->quot_code_offset_to_scan(obj.value(), ofs));
}

cell factor_vm::compute_entry_point_address(cell obj) {
  switch (tagged<object>(obj).type()) {
    case WORD_TYPE:
      return untag<word>(obj)->entry_point;
    case QUOTATION_TYPE:
      return untag<quotation>(obj)->entry_point;
    default:
      critical_error("Expected word or quotation", obj);
      return 0;
  }
}

cell factor_vm::compute_entry_point_pic_address(word* w, cell tagged_quot) {
  if (!to_boolean(tagged_quot) || max_pic_size == 0)
    return w->entry_point;
  quotation* q = untag<quotation>(tagged_quot);
  if (quotation_compiled_p(q))
    return q->entry_point;
  return w->entry_point;
}

cell factor_vm::compute_entry_point_pic_address(cell w_) {
  tagged<word> w(w_);
  return compute_entry_point_pic_address(w.untagged(), w->pic_def);
}

cell factor_vm::compute_entry_point_pic_tail_address(cell w_) {
  tagged<word> w(w_);
  return compute_entry_point_pic_address(w.untagged(), w->pic_tail_def);
}

cell factor_vm::code_block_owner(code_block* compiled) {
  tagged<object> owner(compiled->owner);

  /* Cold generic word call sites point to quotations that call the
     inline-cache-miss and inline-cache-miss-tail primitives. */
  if (owner.type_p(QUOTATION_TYPE)) {
    tagged<quotation> quot(owner.as<quotation>());
    tagged<array> elements(quot->array);

    FACTOR_ASSERT(array_capacity(elements.untagged()) == 5);
    FACTOR_ASSERT(array_nth(elements.untagged(), 4) ==
                      special_objects[PIC_MISS_WORD] ||
                  array_nth(elements.untagged(), 4) ==
                      special_objects[PIC_MISS_TAIL_WORD]);

    tagged<wrapper> word_wrapper(array_nth(elements.untagged(), 0));
    return word_wrapper->object;
  } else
    return compiled->owner;
}

struct update_word_references_relocation_visitor {
  factor_vm* parent;
  bool reset_inline_caches;

  update_word_references_relocation_visitor(factor_vm* parent,
                                            bool reset_inline_caches)
      : parent(parent), reset_inline_caches(reset_inline_caches) {}

  void operator()(instruction_operand op) {
    code_block* compiled = op.load_code_block();
    switch (op.rel_type()) {
      case RT_ENTRY_POINT: {
        cell owner = compiled->owner;
        if (to_boolean(owner))
          op.store_value(parent->compute_entry_point_address(owner));
        break;
      }
      case RT_ENTRY_POINT_PIC: {
        if (reset_inline_caches || !compiled->pic_p()) {
          cell owner = parent->code_block_owner(compiled);
          if (to_boolean(owner))
            op.store_value(parent->compute_entry_point_pic_address(owner));
        }
        break;
      }
      case RT_ENTRY_POINT_PIC_TAIL: {
        if (reset_inline_caches || !compiled->pic_p()) {
          cell owner = parent->code_block_owner(compiled);
          if (to_boolean(owner))
            op.store_value(parent->compute_entry_point_pic_tail_address(owner));
        }
        break;
      }
      default:
        break;
    }
  }
};

/* Relocate new code blocks completely; updating references to literals,
   dlsyms, and words. For all other words in the code heap, we only need
   to update references to other words, without worrying about literals
   or dlsyms. */
void factor_vm::update_word_references(code_block* compiled,
                                       bool reset_inline_caches) {
  if (code->uninitialized_p(compiled))
    initialize_code_block(compiled);
  /* update_word_references() is always applied to every block in
     the code heap. Since it resets all call sites to point to
     their canonical entry point (cold entry point for non-tail calls,
     standard entry point for tail calls), it means that no PICs
     are referenced after this is done. So instead of polluting
     the code heap with dead PICs that will be freed on the next
     GC, we add them to the free list immediately. */
  else if (reset_inline_caches && compiled->pic_p())
    code->free(compiled);
  else {
    update_word_references_relocation_visitor visitor(this,
                                                      reset_inline_caches);
    compiled->each_instruction_operand(visitor);
    compiled->flush_icache();
  }
}

/* Look up an external library symbol referenced by a compiled code block */
cell factor_vm::compute_dlsym_address(array* parameters, cell index) {
  cell symbol = array_nth(parameters, index);
  cell library = array_nth(parameters, index + 1);

  dll* d = (to_boolean(library) ? untag<dll>(library) : NULL);

  void* undefined_symbol = (void*)factor::undefined_symbol;
  undefined_symbol = FUNCTION_CODE_POINTER(undefined_symbol);
  if (d != NULL && !d->handle)
    return (cell)undefined_symbol;

  switch (tagged<object>(symbol).type()) {
    case BYTE_ARRAY_TYPE: {
      symbol_char* name = alien_offset(symbol);
      void* sym = ffi_dlsym(d, name);

      if (sym)
        return (cell)sym;
      else
        return (cell)undefined_symbol;
    }
    case ARRAY_TYPE: {
      array* names = untag<array>(symbol);
      for (cell i = 0; i < array_capacity(names); i++) {
        symbol_char* name = alien_offset(array_nth(names, i));
        void* sym = ffi_dlsym(d, name);

        if (sym)
          return (cell)sym;
      }
      return (cell)undefined_symbol;
    }
    default:
      return -1;
  }
}

#ifdef FACTOR_PPC
cell factor_vm::compute_dlsym_toc_address(array* parameters, cell index) {
  cell symbol = array_nth(parameters, index);
  cell library = array_nth(parameters, index + 1);

  dll* d = (to_boolean(library) ? untag<dll>(library) : NULL);

  void* undefined_toc = (void*)factor::undefined_symbol;
  undefined_toc = FUNCTION_TOC_POINTER(undefined_toc);
  if (d != NULL && !d->handle)
    return (cell)undefined_toc;

  switch (tagged<object>(symbol).type()) {
    case BYTE_ARRAY_TYPE: {
      symbol_char* name = alien_offset(symbol);
      void* toc = ffi_dlsym_toc(d, name);
      if (toc)
        return (cell)toc;
      else
        return (cell)undefined_toc;
    }
    case ARRAY_TYPE: {
      array* names = untag<array>(symbol);
      for (cell i = 0; i < array_capacity(names); i++) {
        symbol_char* name = alien_offset(array_nth(names, i));
        void* toc = ffi_dlsym_toc(d, name);

        if (toc)
          return (cell)toc;
      }
      return (cell)undefined_toc;
    }
    default:
      return -1;
  }
}
#endif

cell factor_vm::compute_vm_address(cell arg) {
  return (cell)this + untag_fixnum(arg);
}

cell factor_vm::lookup_external_address(relocation_type rel_type,
                                        code_block *compiled,
                                        array* parameters,
                                        cell index) {
  switch (rel_type) {
    case RT_DLSYM:
      return compute_dlsym_address(parameters, index);
    case RT_THIS:
      return compiled->entry_point();
    case RT_MEGAMORPHIC_CACHE_HITS:
      return (cell)&dispatch_stats.megamorphic_cache_hits;
    case RT_VM:
      return compute_vm_address(array_nth(parameters, index));
    case RT_CARDS_OFFSET:
      return cards_offset;
    case RT_DECKS_OFFSET:
      return decks_offset;
#ifdef WINDOWS
    case RT_EXCEPTION_HANDLER:
      return (cell)&factor::exception_handler;
#endif
#ifdef FACTOR_PPC
    case RT_DLSYM_TOC:
      return compute_dlsym_toc_address(parameters, index);
#endif
    case RT_INLINE_CACHE_MISS:
      return (cell)&factor::inline_cache_miss;
    case RT_SAFEPOINT:
      return (cell)code->safepoint_page;
    default:
      return -1;
  }
}

cell factor_vm::compute_external_address(instruction_operand op) {
  code_block* compiled = op.compiled;
  array* parameters = to_boolean(compiled->parameters)
      ? untag<array>(compiled->parameters)
      : NULL;
  cell idx = op.index;
  relocation_type rel_type = op.rel_type();

  cell ext_addr = lookup_external_address(rel_type, compiled, parameters, idx);
  if (ext_addr == (cell)-1) {
    ostringstream ss;
    print_obj(ss, compiled->owner);
    ss << ": ";
    cell arg;
    if (rel_type == RT_DLSYM || rel_type == RT_DLSYM_TOC) {
      ss << "Bad symbol specifier in compute_external_address";
      arg = array_nth(parameters, idx);
    } else {
      ss << "Bad rel type in compute_external_address";
      arg = rel_type;
    }
    critical_error(ss.str().c_str(), arg);
  }
  return ext_addr;
}

cell factor_vm::compute_here_address(cell arg, cell offset,
                                     code_block* compiled) {
  fixnum n = untag_fixnum(arg);
  if (n >= 0)
    return compiled->entry_point() + offset + n;
  return compiled->entry_point() - n;
}

struct initial_code_block_visitor {
  factor_vm* parent;
  cell literals;
  cell literal_index;

  initial_code_block_visitor(factor_vm* parent, cell literals)
      : parent(parent), literals(literals), literal_index(0) {}

  cell next_literal() {
    return array_nth(untag<array>(literals), literal_index++);
  }

  fixnum compute_operand_value(instruction_operand op) {
    switch (op.rel_type()) {
      case RT_LITERAL:
        return next_literal();
      case RT_ENTRY_POINT:
        return parent->compute_entry_point_address(next_literal());
      case RT_ENTRY_POINT_PIC:
        return parent->compute_entry_point_pic_address(next_literal());
      case RT_ENTRY_POINT_PIC_TAIL:
        return parent->compute_entry_point_pic_tail_address(next_literal());
      case RT_HERE:
        return parent->compute_here_address(
            next_literal(), op.rel_offset(), op.compiled);
      case RT_UNTAGGED:
        return untag_fixnum(next_literal());
      default:
        return parent->compute_external_address(op);
    }
  }

  void operator()(instruction_operand op) {
    op.store_value(compute_operand_value(op));
  }
};

/* Perform all fixups on a code block */
void factor_vm::initialize_code_block(code_block* compiled, cell literals) {
  initial_code_block_visitor visitor(this, literals);
  compiled->each_instruction_operand(visitor);
  compiled->flush_icache();

  /* next time we do a minor GC, we have to trace this code block, since
     the newly-installed instruction operands might point to literals in
     nursery or aging */
  code->write_barrier(compiled);
}

void factor_vm::initialize_code_block(code_block* compiled) {
  std::map<code_block*, cell>::iterator iter =
      code->uninitialized_blocks.find(compiled);
  initialize_code_block(compiled, iter->second);
  code->uninitialized_blocks.erase(iter);
}

/* Fixup labels. This is done at compile time, not image load time */
void factor_vm::fixup_labels(array* labels, code_block* compiled) {
  cell size = array_capacity(labels);

  for (cell i = 0; i < size; i += 3) {
    relocation_class rel_class =
        (relocation_class) untag_fixnum(array_nth(labels, i));
    cell offset = untag_fixnum(array_nth(labels, i + 1));
    cell target = untag_fixnum(array_nth(labels, i + 2));

    relocation_entry new_entry(RT_HERE, rel_class, offset);

    instruction_operand op(new_entry, compiled, 0);
    op.store_value(target + compiled->entry_point());
  }
}

/* Might GC */
/* Allocates memory */
code_block* factor_vm::allot_code_block(cell size, code_block_type type) {
  code_block* block = code->allocator->allot(size + sizeof(code_block));

  /* If allocation failed, do a full GC and compact the code heap.
     A full GC that occurs as a result of the data heap filling up does not
     trigger a compaction. This setup ensures that most GCs do not compact
     the code heap, but if the code fills up, it probably means it will be
     fragmented after GC anyway, so its best to compact. */
  if (block == NULL) {
    primitive_compact_gc();
    block = code->allocator->allot(size + sizeof(code_block));

    /* Insufficient room even after code GC, give up */
    if (block == NULL) {
      std::cout << "Code heap used: " << code->allocator->occupied_space()
                << "\n";
      std::cout << "Code heap free: " << code->allocator->free_space() << "\n";
      fatal_error("Out of memory in add-compiled-block", 0);
    }
  }

  block->set_type(type);
  return block;
}

/* Might GC */
/* Allocates memory */
code_block* factor_vm::add_code_block(code_block_type type, cell code_,
                                      cell labels_, cell owner_,
                                      cell relocation_, cell parameters_,
                                      cell literals_,
                                      cell frame_size_untagged) {
  data_root<byte_array> code(code_, this);
  data_root<object> labels(labels_, this);
  data_root<object> owner(owner_, this);
  data_root<byte_array> relocation(relocation_, this);
  data_root<array> parameters(parameters_, this);
  data_root<array> literals(literals_, this);

  cell code_length = array_capacity(code.untagged());
  code_block* compiled = allot_code_block(code_length, type);

  compiled->owner = owner.value();

  /* slight space optimization */
  if (relocation.type() == BYTE_ARRAY_TYPE &&
      array_capacity(relocation.untagged()) == 0)
    compiled->relocation = false_object;
  else
    compiled->relocation = relocation.value();

  if (parameters.type() == ARRAY_TYPE &&
      array_capacity(parameters.untagged()) == 0)
    compiled->parameters = false_object;
  else
    compiled->parameters = parameters.value();

  /* code */
  memcpy(compiled + 1, code.untagged() + 1, code_length);

  /* fixup labels */
  if (to_boolean(labels.value()))
    fixup_labels(labels.as<array>().untagged(), compiled);

  compiled->set_stack_frame_size(frame_size_untagged);

  /* Once we are ready, fill in literal and word references in this code
     block's instruction operands. In most cases this is done right after this
     method returns, except when compiling words with the non-optimizing
     compiler at the beginning of bootstrap */
  this->code->uninitialized_blocks.insert(
      std::make_pair(compiled, literals.value()));
  this->code->all_blocks.insert((cell)compiled);

  /* next time we do a minor GC, we have to trace this code block, since
     the fields of the code_block struct might point into nursery or aging */
  this->code->write_barrier(compiled);

  return compiled;
}

/* References to undefined symbols are patched up to call this function on
   image load. It finds the symbol and library, and throws an error. */
void factor_vm::undefined_symbol() {
  cell frame = ctx->callstack_top;
  cell return_address = *(cell*)frame;
  code_block* compiled = code->code_block_for_address(return_address);

  /* Find the RT_DLSYM relocation nearest to the given return
     address. */
  cell symbol = false_object;
  cell library = false_object;

  auto find_symbol_at_address_visitor = [&](instruction_operand op) {
    if (op.rel_type() == RT_DLSYM && op.pointer <= return_address) {
      array* parameters = untag<array>(compiled->parameters);
      cell index = op.index;
      symbol = array_nth(parameters, index);
      library = array_nth(parameters, index + 1);
    }
  };
  compiled->each_instruction_operand(find_symbol_at_address_visitor);

  if (!to_boolean(symbol))
    critical_error("Can't find RT_DLSYM at return address", return_address);
  else
    general_error(ERROR_UNDEFINED_SYMBOL, symbol, library);
}

void undefined_symbol() {
  return current_vm()->undefined_symbol();
}
}
