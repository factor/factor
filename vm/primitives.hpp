namespace factor
{

/* Generated with PRIMITIVE in primitives.cpp */

#define EACH_PRIMITIVE(_) \
	_(alien_address) \
	_(all_instances) \
	_(array) \
	_(array_to_quotation) \
	_(become) \
	_(bignum_add) \
	_(bignum_and) \
	_(bignum_bitp) \
	_(bignum_divint) \
	_(bignum_divmod) \
	_(bignum_eq) \
	_(bignum_greater) \
	_(bignum_greatereq) \
	_(bignum_less) \
	_(bignum_lesseq) \
	_(bignum_log2) \
	_(bignum_mod) \
	_(bignum_multiply) \
	_(bignum_not) \
	_(bignum_or) \
	_(bignum_shift) \
	_(bignum_subtract) \
	_(bignum_to_fixnum) \
	_(bignum_to_float) \
	_(bignum_xor) \
	_(bits_double) \
	_(bits_float) \
	_(byte_array) \
	_(byte_array_to_bignum) \
	_(callback) \
	_(callstack) \
	_(callstack_bounds) \
	_(callstack_for) \
	_(callstack_to_array) \
	_(check_datastack) \
	_(clone) \
	_(code_blocks) \
	_(code_room) \
	_(compact_gc) \
	_(compute_identity_hashcode) \
	_(context_object) \
	_(context_object_for) \
	_(current_callback) \
	_(data_room) \
	_(datastack) \
	_(datastack_for) \
	_(die) \
	_(disable_gc_events) \
	_(dispatch_stats) \
	_(displaced_alien) \
	_(dlclose) \
	_(dll_validp) \
	_(dlopen) \
	_(dlsym) \
	_(double_bits) \
	_(enable_gc_events) \
	_(existsp) \
	_(exit) \
	_(fclose) \
	_(fflush) \
	_(fgetc) \
	_(fixnum_divint) \
	_(fixnum_divmod) \
	_(fixnum_shift) \
	_(fixnum_to_bignum) \
	_(fixnum_to_float) \
	_(float_add) \
	_(float_bits) \
	_(float_divfloat) \
	_(float_eq) \
	_(float_greater) \
	_(float_greatereq) \
	_(float_less) \
	_(float_lesseq) \
	_(float_mod) \
	_(float_multiply) \
	_(float_subtract) \
	_(float_to_bignum) \
	_(float_to_fixnum) \
	_(fopen) \
	_(format_float) \
	_(fputc) \
	_(fread) \
	_(fseek) \
	_(ftell) \
	_(full_gc) \
	_(fwrite) \
	_(identity_hashcode) \
	_(innermost_stack_frame_executing) \
	_(innermost_stack_frame_scan) \
	_(jit_compile) \
	_(load_locals) \
	_(lookup_method) \
	_(mega_cache_miss) \
	_(minor_gc) \
	_(modify_code_heap) \
	_(nano_count) \
	_(optimized_p) \
	_(profiling) \
	_(quot_compiled_p) \
	_(quotation_code) \
	_(reset_dispatch_stats) \
	_(resize_array) \
	_(resize_byte_array) \
	_(resize_string) \
	_(retainstack) \
	_(retainstack_for) \
	_(save_image) \
	_(save_image_and_exit) \
	_(set_context_object) \
	_(set_datastack) \
	_(set_innermost_stack_frame_quot) \
	_(set_retainstack) \
	_(set_slot) \
	_(set_special_object) \
	_(set_string_nth_fast) \
	_(set_string_nth_slow) \
	_(size) \
	_(sleep) \
	_(special_object) \
	_(string) \
	_(string_nth) \
	_(strip_stack_traces) \
	_(system_micros) \
	_(tuple) \
	_(tuple_boa) \
	_(unimplemented) \
	_(uninitialized_byte_array) \
	_(word) \
	_(word_code) \
	_(wrapper)

#define EACH_ALIEN_PRIMITIVE(_) \
	_(signed_cell,fixnum,from_signed_cell,to_fixnum) \
	_(unsigned_cell,cell,from_unsigned_cell,to_cell) \
	_(signed_8,s64,from_signed_8,to_signed_8) \
	_(unsigned_8,u64,from_unsigned_8,to_unsigned_8) \
	_(signed_4,s32,from_signed_4,to_fixnum) \
	_(unsigned_4,u32,from_unsigned_4,to_cell) \
	_(signed_2,s16,from_signed_2,to_fixnum) \
	_(unsigned_2,u16,from_unsigned_2,to_cell) \
	_(signed_1,s8,from_signed_1,to_fixnum) \
	_(unsigned_1,u8,from_unsigned_1,to_cell) \
	_(float,float,from_float,to_float) \
	_(double,double,from_double,to_double) \
	_(cell,void *,allot_alien,pinned_alien_offset)

#define DECLARE_PRIMITIVE(name) VM_C_API void primitive_##name(factor_vm *parent);

#define DECLARE_ALIEN_PRIMITIVE(name, type, from, to) \
	DECLARE_PRIMITIVE(alien_##name) \
	DECLARE_PRIMITIVE(set_alien_##name)

EACH_PRIMITIVE(DECLARE_PRIMITIVE)
EACH_ALIEN_PRIMITIVE(DECLARE_ALIEN_PRIMITIVE)
}
