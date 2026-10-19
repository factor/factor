template <typename Fixup> struct call_frame_slot_visitor {
  slot_visitor<Fixup>* visitor;

  call_frame_slot_visitor(slot_visitor<Fixup>* visitor)
      : visitor(visitor) {}

  // frame top -> [return address]
  //              [spill area]
  //              ...
  //              [entry_point]
  //              [size]

  void operator()(cell frame_top, cell size, code_block* owner, cell addr) {
    (void)size;
    cell return_address = owner->offset(addr);

    code_block* compiled =
        Fixup::translated_code_block_map ? owner
                                         : visitor->fixup.translate_code(owner);
    gc_info* info = compiled->block_gc_info();

    FACTOR_ASSERT(return_address < compiled->size());
    cell callsite = info->return_address_index(return_address);
    if (callsite == (cell)-1)
      return;

#ifdef DEBUG_GC_MAPS
    FACTOR_PRINT("call frame code block " << compiled << " with offset "
                 << return_address);
#endif
#ifdef FACTOR_GC_ROOTS_AT_PREDECESSOR_SP
    // On m88k the callee header holds its caller's return PC. The matching
    // bitmap therefore describes spills above the predecessor stack pointer.
    cell* stack_pointer = (cell*)(frame_top + size);
#else
    cell* stack_pointer = (cell*)frame_top;
#endif
    uint8_t* bitmap = info->gc_info_bitmap();

    // Subtract old value of base pointer from every derived pointer.
    for (cell spill_slot = 0; spill_slot < info->derived_root_count;
         spill_slot++) {
      uint32_t base_pointer = info->lookup_base_pointer(callsite, spill_slot);
      if (base_pointer != (uint32_t)-1) {
#ifdef DEBUG_GC_MAPS
        FACTOR_PRINT("visiting derived root " << spill_slot
                     << " with base pointer " << base_pointer);
#endif
        stack_pointer[spill_slot] -= stack_pointer[base_pointer];
      }
    }

    auto restore_derived_roots = [&]() {
      for (cell spill_slot = 0; spill_slot < info->derived_root_count;
           spill_slot++) {
        uint32_t base_pointer = info->lookup_base_pointer(callsite, spill_slot);
        if (base_pointer != (uint32_t)-1)
          stack_pointer[spill_slot] += stack_pointer[base_pointer];
      }
    };

    // Update all GC roots, including base pointers.
    cell callsite_gc_roots = info->callsite_gc_roots(callsite);
    try {
      for (cell spill_slot = 0; spill_slot < info->gc_root_count; spill_slot++) {
        if (bitmap_p(bitmap, callsite_gc_roots + spill_slot)) {
          #ifdef DEBUG_GC_MAPS
          FACTOR_PRINT("visiting GC root " << spill_slot);
          #endif
          visitor->visit_handle(stack_pointer + spill_slot);
        }
      }
    } catch (...) {
      // A copying collection can run out of space after forwarding only some
      // bases. Restore pointers using their current bases before GC retries.
      restore_derived_roots();
      throw;
    }
    restore_derived_roots();
  }
};
