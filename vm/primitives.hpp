namespace factor {

// Generated with PRIMITIVE in primitives.cpp

#define EACH_PRIMITIVE(_)                                                      \
  _(alien_address) _(all_instances) _(array) _(array_to_quotation) _(become)   \
      _(bignum_add) _(bignum_and) _(bignum_bitp) _(bignum_divint)              \
      _(bignum_divmod) _(bignum_eq) _(bignum_greater) _(bignum_greatereq)      \
      _(bignum_less) _(bignum_lesseq) _(bignum_log2) _(bignum_mod)             \
      _(bignum_gcd) _(bignum_multiply) _(bignum_not) _(bignum_or)              \
      _(bignum_shift) _(bignum_subtract) _(bignum_to_fixnum)                   \
      _(bignum_to_fixnum_strict) _(bignum_xor) _(bits_double) _(bits_float)    \
      _(byte_array) _(callback) _(callback_room)                               \
      _(callstack_bounds) _(callstack_for) _(callstack_to_array)               \
      _(check_datastack) _(clone) _(code_blocks) _(code_room)                  \
      _(compact_gc) _(compute_identity_hashcode) _(context_object)             \
      _(context_object_for) _(current_callback) _(data_room)                   \
      _(datastack_for) _(die) _(disable_ctrl_break) _(disable_gc_events)       \
      _(dispatch_stats)                                                        \
      _(displaced_alien) _(dlclose) _(dll_validp) _(dlopen) _(dlsym)           \
      _(double_bits) _(enable_ctrl_break) _(enable_gc_events)                  \
      _(existsp) _(exit)                                                       \
      _(fclose) _(fflush) _(fgetc) _(fixnum_divint) _(fixnum_divmod)           \
      _(fixnum_shift) _(fixnum_to_bignum) _(fixnum_to_float) _(float_add)      \
      _(float_bits) _(float_divfloat) _(float_eq) _(float_greater)             \
      _(float_greatereq) _(float_less) _(float_lesseq) _(float_multiply)       \
      _(float_subtract) _(float_to_bignum) _(float_to_fixnum) _(fopen)         \
      _(format_float) _(fputc) _(fread) _(free_callback) _(fseek) _(ftell)     \
      _(full_gc) _(fwrite) _(get_samples) _(identity_hashcode)                 \
      _(innermost_stack_frame_executing) _(innermost_stack_frame_scan)         \
      _(jit_compile) _(load_locals) _(lookup_method) _(mega_cache_miss)        \
      _(minor_gc) _(modify_code_heap) _(nano_count) _(quotation_code)          \
      _(quotation_compiled_p) _(reset_dispatch_stats) _(resize_array)          \
      _(resize_byte_array) _(resize_string) _(retainstack_for)                 \
      _(save_image) _(set_context_object) _(set_datastack)                     \
      _(set_innermost_stack_frame_quotation) _(set_profiling)                  \
      _(set_retainstack) _(set_slot) _(set_special_object)                     \
      _(set_string_nth_fast) _(size) _(sleep) _(special_object) _(string)      \
      _(strip_stack_traces) _(tuple) _(tuple_boa)                              \
      _(uninitialized_byte_array) _(word) _(word_code) _(word_optimized_p)     \
      _(wrapper)

#define EACH_ALIEN_PRIMITIVE(_)                               \
      _(signed_8, int64_t, from_signed_8, to_signed_8)        \
      _(unsigned_8, uint64_t, from_unsigned_8, to_unsigned_8) \
      _(signed_4, int32_t, from_signed_cell, to_fixnum)       \
      _(unsigned_4, uint32_t, from_unsigned_cell, to_cell)    \
      _(signed_2, int16_t, from_signed_cell, to_fixnum)       \
      _(unsigned_2, uint16_t, from_unsigned_cell, to_cell)    \
      _(signed_1, int8_t, from_signed_cell, to_fixnum)        \
      _(unsigned_1, uint8_t, from_unsigned_cell, to_cell)     \
      _(float, float, allot_float, to_float)                  \
      _(double, double, allot_float, to_double)               \
      _(cell, cell, allot_alien, pinned_alien_offset)

#define DECLARE_PRIMITIVE(name) \
  VM_C_API void primitive_##name(factor_vm * parent);

#define DECLARE_ALIEN_PRIMITIVE(name, type, from, to) \
  DECLARE_PRIMITIVE(alien_##name)                     \
  DECLARE_PRIMITIVE(set_alien_##name)

EACH_PRIMITIVE(DECLARE_PRIMITIVE)
EACH_ALIEN_PRIMITIVE(DECLARE_ALIEN_PRIMITIVE)
}
