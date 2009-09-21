#include "vm-data.hpp"

namespace factor
{

struct factorvm : factorvmdata {

	// segments
	inline cell align_page(cell a);

	// contexts
	void reset_datastack();
	void reset_retainstack();
	void fix_stacks();
	void save_stacks();
	context *alloc_context();
	void dealloc_context(context *old_context);
	void nest_stacks();
	void unnest_stacks();
	void init_stacks(cell ds_size_, cell rs_size_);
	bool stack_to_array(cell bottom, cell top);
	cell array_to_stack(array *array, cell bottom);
	inline void vmprim_datastack();
	inline void vmprim_retainstack();
	inline void vmprim_set_datastack();
	inline void vmprim_set_retainstack();
	inline void vmprim_check_datastack();

	// run
	inline void vmprim_getenv();
	inline void vmprim_setenv();
	inline void vmprim_exit();
	inline void vmprim_micros();
	inline void vmprim_sleep();
	inline void vmprim_set_slot();
	inline void vmprim_load_locals();
	cell clone_object(cell obj_);
	inline void vmprim_clone();

	// profiler
	void init_profiler();
	code_block *compile_profiling_stub(cell word_);
	void set_profiling(bool profiling);
	inline void vmprim_profiling();

	// errors
	void out_of_memory();
	void critical_error(const char* msg, cell tagged);
	void throw_error(cell error, stack_frame *callstack_top);
	void not_implemented_error();
	bool in_page(cell fault, cell area, cell area_size, int offset);
	void memory_protection_error(cell addr, stack_frame *native_stack);
	void signal_error(int signal, stack_frame *native_stack);
	void divide_by_zero_error();
	void fp_trap_error(unsigned int fpu_status, stack_frame *signal_callstack_top);
	inline void vmprim_call_clear();
	inline void vmprim_unimplemented();
	void memory_signal_handler_impl();
	void misc_signal_handler_impl();
	void fp_signal_handler_impl();
	void type_error(cell type, cell tagged);
	void general_error(vm_error_type error, cell arg1, cell arg2, stack_frame *native_stack);

	//callstack

	// bignum
	int bignum_equal_p(bignum * x, bignum * y);
	enum bignum_comparison bignum_compare(bignum * x, bignum * y);
	bignum *bignum_add(bignum * x, bignum * y);
	bignum *bignum_subtract(bignum * x, bignum * y);
	bignum *bignum_multiply(bignum * x, bignum * y);
	void bignum_divide(bignum * numerator, bignum * denominator, bignum * * quotient, bignum * * remainder);
	bignum *bignum_quotient(bignum * numerator, bignum * denominator);
	bignum *bignum_remainder(bignum * numerator, bignum * denominator);
	cell bignum_to_cell(bignum * bignum);
	fixnum bignum_to_fixnum(bignum * bignum);
	s64 bignum_to_long_long(bignum * bignum);
	u64 bignum_to_ulong_long(bignum * bignum);
	double bignum_to_double(bignum * bignum);
	bignum *double_to_bignum(double x);
	int bignum_equal_p_unsigned(bignum * x, bignum * y);
	enum bignum_comparison bignum_compare_unsigned(bignum * x, bignum * y);
	bignum *bignum_add_unsigned(bignum * x, bignum * y, int negative_p);
	bignum *bignum_subtract_unsigned(bignum * x, bignum * y);
	bignum *bignum_multiply_unsigned(bignum * x, bignum * y, int negative_p);
	bignum *bignum_multiply_unsigned_small_factor(bignum * x, bignum_digit_type y,int negative_p);
	void bignum_destructive_add(bignum * bignum, bignum_digit_type n);
	void bignum_destructive_scale_up(bignum * bignum, bignum_digit_type factor);
	void bignum_divide_unsigned_large_denominator(bignum * numerator, bignum * denominator, 
												  bignum * * quotient, bignum * * remainder, int q_negative_p, int r_negative_p);
	void bignum_divide_unsigned_normalized(bignum * u, bignum * v, bignum * q);
	bignum_digit_type bignum_divide_subtract(bignum_digit_type * v_start, bignum_digit_type * v_end, 
											 bignum_digit_type guess, bignum_digit_type * u_start);
	void bignum_divide_unsigned_medium_denominator(bignum * numerator,bignum_digit_type denominator, 
												   bignum * * quotient, bignum * * remainder,int q_negative_p, int r_negative_p);
	void bignum_destructive_normalization(bignum * source, bignum * target, int shift_left);
	void bignum_destructive_unnormalization(bignum * bignum, int shift_right);
	bignum_digit_type bignum_digit_divide(bignum_digit_type uh, bignum_digit_type ul, 
										  bignum_digit_type v, bignum_digit_type * q) /* return value */;
	bignum_digit_type bignum_digit_divide_subtract(bignum_digit_type v1, bignum_digit_type v2, 
												   bignum_digit_type guess, bignum_digit_type * u);
	void bignum_divide_unsigned_small_denominator(bignum * numerator, bignum_digit_type denominator, 
												  bignum * * quotient, bignum * * remainder,int q_negative_p, int r_negative_p);
	bignum_digit_type bignum_destructive_scale_down(bignum * bignum, bignum_digit_type denominator);
	bignum * bignum_remainder_unsigned_small_denominator(bignum * n, bignum_digit_type d, int negative_p);
	bignum *bignum_digit_to_bignum(bignum_digit_type digit, int negative_p);
	bignum *allot_bignum(bignum_length_type length, int negative_p);
	bignum * allot_bignum_zeroed(bignum_length_type length, int negative_p);
	bignum *bignum_shorten_length(bignum * bignum, bignum_length_type length);
	bignum *bignum_trim(bignum * bignum);
	bignum *bignum_new_sign(bignum * x, int negative_p);
	bignum *bignum_maybe_new_sign(bignum * x, int negative_p);
	void bignum_destructive_copy(bignum * source, bignum * target);
	bignum *bignum_bitwise_not(bignum * x);
	bignum *bignum_arithmetic_shift(bignum * arg1, fixnum n);
	bignum *bignum_bitwise_and(bignum * arg1, bignum * arg2);
	bignum *bignum_bitwise_ior(bignum * arg1, bignum * arg2);
	bignum *bignum_bitwise_xor(bignum * arg1, bignum * arg2);
	bignum *bignum_magnitude_ash(bignum * arg1, fixnum n);
	bignum *bignum_pospos_bitwise_op(int op, bignum * arg1, bignum * arg2);
	bignum *bignum_posneg_bitwise_op(int op, bignum * arg1, bignum * arg2);
	bignum *bignum_negneg_bitwise_op(int op, bignum * arg1, bignum * arg2);
	void bignum_negate_magnitude(bignum * arg);
	bignum *bignum_integer_length(bignum * x);
	int bignum_logbitp(int shift, bignum * arg);
	int bignum_unsigned_logbitp(int shift, bignum * bignum);
	bignum *digit_stream_to_bignum(unsigned int n_digits, unsigned int (*producer)(unsigned int, factorvm *), unsigned int radix, int negative_p);

	//data_heap
	cell init_zone(zone *z, cell size, cell start);
	void init_card_decks();
	data_heap *alloc_data_heap(cell gens, cell young_size,cell aging_size,cell tenured_size);
	data_heap *grow_data_heap(data_heap *data, cell requested_bytes);
	void dealloc_data_heap(data_heap *data);
	void clear_cards(cell from, cell to);
	void clear_decks(cell from, cell to);
	void clear_allot_markers(cell from, cell to);
	void reset_generation(cell i);
	void reset_generations(cell from, cell to);
	void set_data_heap(data_heap *data_);
	void init_data_heap(cell gens,cell young_size,cell aging_size,cell tenured_size,bool secure_gc_);
	cell untagged_object_size(object *pointer);
	cell unaligned_object_size(object *pointer);
	inline void vmprim_size();
	cell binary_payload_start(object *pointer);
	inline void vmprim_data_room();
	void begin_scan();
	void end_scan();
	inline void vmprim_begin_scan();
	cell next_object();
	inline void vmprim_next_object();
	inline void vmprim_end_scan();
	template<typename T> void each_object(T &functor);
	cell find_all_words();
	cell object_size(cell tagged);

	
	//write barrier
	inline card *addr_to_card(cell a);
	inline cell card_to_addr(card *c);
	inline cell card_offset(card *c);
	inline card_deck *addr_to_deck(cell a);
	inline cell deck_to_addr(card_deck *c);
	inline card *deck_to_card(card_deck *d);
	inline card *addr_to_allot_marker(object *a);
	inline void write_barrier(object *obj);
	inline void allot_barrier(object *address);


	//data_gc
	void init_data_gc();
	object *copy_untagged_object_impl(object *pointer, cell size);
	object *copy_object_impl(object *untagged);
	bool should_copy_p(object *untagged);
	object *resolve_forwarding(object *untagged);
	template <typename T> T *copy_untagged_object(T *untagged);
	cell copy_object(cell pointer);
	void copy_handle(cell *handle);
	void copy_card(card *ptr, cell gen, cell here);
	void copy_card_deck(card_deck *deck, cell gen, card mask, card unmask);
	void copy_gen_cards(cell gen);
	void copy_cards();
	void copy_stack_elements(segment *region, cell top);
	void copy_registered_locals();
	void copy_registered_bignums();
	void copy_roots();
	cell copy_next_from_nursery(cell scan);
	cell copy_next_from_aging(cell scan);
	cell copy_next_from_tenured(cell scan);
	void copy_reachable_objects(cell scan, cell *end);
	void begin_gc(cell requested_bytes);
	void end_gc(cell gc_elapsed);
	void garbage_collection(cell gen,bool growing_data_heap_,cell requested_bytes);
	void gc();
	inline void vmprim_gc();
	inline void vmprim_gc_stats();
	void clear_gc_stats();
	inline void vmprim_become();
	void inline_gc(cell *gc_roots_base, cell gc_roots_size);
	inline bool collecting_accumulation_gen_p();
	inline object *allot_zone(zone *z, cell a);
	inline object *allot_object(header header, cell size);
	template <typename TYPE> TYPE *allot(cell size);
	inline void check_data_pointer(object *pointer);
	inline void check_tagged_pointer(cell tagged);
	inline void vmprim_clear_gc_stats();

	// generic arrays
	template <typename T> T *allot_array_internal(cell capacity);
	template <typename T> bool reallot_array_in_place_p(T *array, cell capacity);
	template <typename TYPE> TYPE *reallot_array(TYPE *array_, cell capacity);

	//debug
	void print_chars(string* str);
	void print_word(word* word, cell nesting);
	void print_factor_string(string* str);
	void print_array(array* array, cell nesting);
	void print_tuple(tuple *tuple, cell nesting);
	void print_nested_obj(cell obj, fixnum nesting);
	void print_obj(cell obj);
	void print_objects(cell *start, cell *end);
	void print_datastack();
	void print_retainstack();
	void print_stack_frame(stack_frame *frame);
	void print_callstack();
	void dump_cell(cell x);
	void dump_memory(cell from, cell to);
	void dump_zone(zone *z);
	void dump_generations();
	void dump_objects(cell type);
	void find_data_references_step(cell *scan);
	void find_data_references(cell look_for_);
	void dump_code_heap();
	void factorbug();
	inline void vmprim_die();

	//arrays
	array *allot_array(cell capacity, cell fill_);
	inline void vmprim_array();
	cell allot_array_1(cell obj_);
	cell allot_array_2(cell v1_, cell v2_);
	cell allot_array_4(cell v1_, cell v2_, cell v3_, cell v4_);
	inline void vmprim_resize_array();
	inline void set_array_nth(array *array, cell slot, cell value);

	//strings
	cell string_nth(string* str, cell index);
	void set_string_nth_fast(string *str, cell index, cell ch);
	void set_string_nth_slow(string *str_, cell index, cell ch);
	void set_string_nth(string *str, cell index, cell ch);
	string *allot_string_internal(cell capacity);
	void fill_string(string *str_, cell start, cell capacity, cell fill);
	string *allot_string(cell capacity, cell fill);
	inline void vmprim_string();
	bool reallot_string_in_place_p(string *str, cell capacity);
	string* reallot_string(string *str_, cell capacity);
	inline void vmprim_resize_string();
	inline void vmprim_string_nth();
	inline void vmprim_set_string_nth_fast();
	inline void vmprim_set_string_nth_slow();

	//booleans
	void box_boolean(bool value);
	bool to_boolean(cell value);
	inline cell tag_boolean(cell untagged);

	//byte arrays
	byte_array *allot_byte_array(cell size);
	inline void vmprim_byte_array();
	inline void vmprim_uninitialized_byte_array();
	inline void vmprim_resize_byte_array();

	//tuples
	tuple *allot_tuple(cell layout_);
	inline void vmprim_tuple();
	inline void vmprim_tuple_boa();

	//words
	word *allot_word(cell vocab_, cell name_);
	inline void vmprim_word();
	inline void vmprim_word_xt();
	void update_word_xt(cell w_);
	inline void vmprim_optimized_p();
	inline void vmprim_wrapper();

	//math
	inline void vmprim_bignum_to_fixnum();
	inline void vmprim_float_to_fixnum();
	inline void vmprim_fixnum_divint();
	inline void vmprim_fixnum_divmod();
	bignum *fixnum_to_bignum(fixnum);
	bignum *cell_to_bignum(cell);
	bignum *long_long_to_bignum(s64 n);
	bignum *ulong_long_to_bignum(u64 n);
	inline fixnum sign_mask(fixnum x);
	inline fixnum branchless_max(fixnum x, fixnum y);
	inline fixnum branchless_abs(fixnum x);
	inline void vmprim_fixnum_shift();
	inline void vmprim_fixnum_to_bignum();
	inline void vmprim_float_to_bignum();
	inline void vmprim_bignum_eq();
	inline void vmprim_bignum_add();
	inline void vmprim_bignum_subtract();
	inline void vmprim_bignum_multiply();
	inline void vmprim_bignum_divint();
	inline void vmprim_bignum_divmod();
	inline void vmprim_bignum_mod();
	inline void vmprim_bignum_and();
	inline void vmprim_bignum_or();
	inline void vmprim_bignum_xor();
	inline void vmprim_bignum_shift();
	inline void vmprim_bignum_less();
	inline void vmprim_bignum_lesseq();
	inline void vmprim_bignum_greater();
	inline void vmprim_bignum_greatereq();
	inline void vmprim_bignum_not();
	inline void vmprim_bignum_bitp();
	inline void vmprim_bignum_log2();
	unsigned int bignum_producer(unsigned int digit);
	inline void vmprim_byte_array_to_bignum();
	cell unbox_array_size();
	inline void vmprim_fixnum_to_float();
	inline void vmprim_bignum_to_float();
	inline void vmprim_str_to_float();
	inline void vmprim_float_to_str();
	inline void vmprim_float_eq();
	inline void vmprim_float_add();
	inline void vmprim_float_subtract();
	inline void vmprim_float_multiply();
	inline void vmprim_float_divfloat();
	inline void vmprim_float_mod();
	inline void vmprim_float_less();
	inline void vmprim_float_lesseq();
	inline void vmprim_float_greater();
	inline void vmprim_float_greatereq();
	inline void vmprim_float_bits();
	inline void vmprim_bits_float();
	inline void vmprim_double_bits();
	inline void vmprim_bits_double();
	fixnum to_fixnum(cell tagged);
	cell to_cell(cell tagged);
	void box_signed_1(s8 n);
	void box_unsigned_1(u8 n);
	void box_signed_2(s16 n);
	void box_unsigned_2(u16 n);
	void box_signed_4(s32 n);
	void box_unsigned_4(u32 n);
	void box_signed_cell(fixnum integer);
	void box_unsigned_cell(cell cell);
	void box_signed_8(s64 n);
	s64 to_signed_8(cell obj);
	void box_unsigned_8(u64 n);
	u64 to_unsigned_8(cell obj);
	void box_float(float flo);
	float to_float(cell value);
	void box_double(double flo);
	double to_double(cell value);
	inline void overflow_fixnum_add(fixnum x, fixnum y);
	inline void overflow_fixnum_subtract(fixnum x, fixnum y);
	inline void overflow_fixnum_multiply(fixnum x, fixnum y);
	inline cell allot_integer(fixnum x);
	inline cell allot_cell(cell x);
	inline cell allot_float(double n);
	inline bignum *float_to_bignum(cell tagged);
	inline double bignum_to_float(cell tagged);
	inline double untag_float(cell tagged);
	inline double untag_float_check(cell tagged);
	inline fixnum float_to_fixnum(cell tagged);
	inline double fixnum_to_float(cell tagged);
	template <typename T> T *untag_check(cell value);
	template <typename T> T *untag(cell value);
	
	//io
	void init_c_io();
	void io_error();
	inline void vmprim_fopen();
	inline void vmprim_fgetc();
	inline void vmprim_fread();
	inline void vmprim_fputc();
	inline void vmprim_fwrite();
	inline void vmprim_fseek();
	inline void vmprim_fflush();
	inline void vmprim_fclose();

	//code_gc
	void clear_free_list(heap *heap);
	void new_heap(heap *heap, cell size);
	void add_to_free_list(heap *heap, free_heap_block *block);
	void build_free_list(heap *heap, cell size);
	void assert_free_block(free_heap_block *block);
	free_heap_block *find_free_block(heap *heap, cell size);
	free_heap_block *split_free_block(heap *heap, free_heap_block *block, cell size);
	heap_block *heap_allot(heap *heap, cell size);
	void heap_free(heap *heap, heap_block *block);
	void mark_block(heap_block *block);
	void unmark_marked(heap *heap);
	void free_unmarked(heap *heap, heap_iterator iter);
	void heap_usage(heap *heap, cell *used, cell *total_free, cell *max_free);
	cell heap_size(heap *heap);
	cell compute_heap_forwarding(heap *heap, unordered_map<heap_block *,char *> &forwarding);
	void compact_heap(heap *heap, unordered_map<heap_block *,char *> &forwarding);

	//code_block
	relocation_type relocation_type_of(relocation_entry r);
	relocation_class relocation_class_of(relocation_entry r);
	cell relocation_offset_of(relocation_entry r);
	void flush_icache_for(code_block *block);
	int number_of_parameters(relocation_type type);
	void *object_xt(cell obj);
	void *xt_pic(word *w, cell tagged_quot);
	void *word_xt_pic(word *w);
	void *word_xt_pic_tail(word *w);
	void undefined_symbol();
	void *get_rel_symbol(array *literals, cell index);
	cell compute_relocation(relocation_entry rel, cell index, code_block *compiled);
	void iterate_relocations(code_block *compiled, relocation_iterator iter);
	void store_address_2_2(cell *ptr, cell value);
	void store_address_masked(cell *ptr, fixnum value, cell mask, fixnum shift);
	void store_address_in_code_block(cell klass, cell offset, fixnum absolute_value);
	void update_literal_references_step(relocation_entry rel, cell index, code_block *compiled);
	void update_literal_references(code_block *compiled);
	void copy_literal_references(code_block *compiled);
	void relocate_code_block_step(relocation_entry rel, cell index, code_block *compiled);
	void update_word_references_step(relocation_entry rel, cell index, code_block *compiled);
	void update_word_references(code_block *compiled);
	void update_literal_and_word_references(code_block *compiled);
	void check_code_address(cell address);
	void mark_code_block(code_block *compiled);
	void mark_stack_frame_step(stack_frame *frame);
	void mark_active_blocks(context *stacks);
	void mark_object_code_block(object *object);
	void relocate_code_block(code_block *compiled);
	void fixup_labels(array *labels, code_block *compiled);
	code_block *allot_code_block(cell size);
	code_block *add_code_block(cell type,cell code_,cell labels_,cell relocation_,cell literals_);
	inline bool stack_traces_p()
	{
		return userenv[STACK_TRACES_ENV] != F;
	}

	//code_heap
	void init_code_heap(cell size);
	bool in_code_heap_p(cell ptr);
	void jit_compile_word(cell word_, cell def_, bool relocate);
	void iterate_code_heap(code_heap_iterator iter);
	void copy_code_heap_roots();
	void update_code_heap_words();
	inline void vmprim_modify_code_heap();
	inline void vmprim_code_room();
	code_block *forward_xt(code_block *compiled);
	void forward_frame_xt(stack_frame *frame);
	void forward_object_xts();
	void fixup_object_xts();
	void compact_code_heap();
	inline void check_code_pointer(cell ptr);


	//image
	void init_objects(image_header *h);
	void load_data_heap(FILE *file, image_header *h, vm_parameters *p);
	void load_code_heap(FILE *file, image_header *h, vm_parameters *p);
	bool save_image(const vm_char *filename);
	inline void vmprim_save_image();
	inline void vmprim_save_image_and_exit();
	void data_fixup(cell *cell);
	template <typename T> void code_fixup(T **handle);
	void fixup_word(word *word);
	void fixup_quotation(quotation *quot);
	void fixup_alien(alien *d);
	void fixup_stack_frame(stack_frame *frame);
	void fixup_callstack_object(callstack *stack);
	void relocate_object(object *object);
	void relocate_data();
	void fixup_code_block(code_block *compiled);
	void relocate_code();
	void load_image(vm_parameters *p);

	//callstack
	template<typename T> void iterate_callstack_object(callstack *stack_, T &iterator);
	void check_frame(stack_frame *frame);
	callstack *allot_callstack(cell size);
	stack_frame *fix_callstack_top(stack_frame *top, stack_frame *bottom);
	stack_frame *capture_start();
	inline void vmprim_callstack();
	inline void vmprim_set_callstack();
	code_block *frame_code(stack_frame *frame);
	cell frame_type(stack_frame *frame);
	cell frame_executing(stack_frame *frame);
	stack_frame *frame_successor(stack_frame *frame);
	cell frame_scan(stack_frame *frame);
	inline void vmprim_callstack_to_array();
	stack_frame *innermost_stack_frame(callstack *stack);
	stack_frame *innermost_stack_frame_quot(callstack *callstack);
	inline void vmprim_innermost_stack_frame_executing();
	inline void vmprim_innermost_stack_frame_scan();
	inline void vmprim_set_innermost_stack_frame_quot();
	void save_callstack_bottom(stack_frame *callstack_bottom);
	template<typename T> void iterate_callstack(cell top, cell bottom, T &iterator);
	inline void do_slots(cell obj, void (* iter)(cell *,factorvm*));


	//alien
	char *pinned_alien_offset(cell obj);
	cell allot_alien(cell delegate_, cell displacement);
	inline void vmprim_displaced_alien();
	inline void vmprim_alien_address();
	void *alien_pointer();
	inline void vmprim_dlopen();
	inline void vmprim_dlsym();
	inline void vmprim_dlclose();
	inline void vmprim_dll_validp();
	inline void vmprim_vm_ptr();
	char *alien_offset(cell obj);
	char *unbox_alien();
	void box_alien(void *ptr);
	void to_value_struct(cell src, void *dest, cell size);
	void box_value_struct(void *src, cell size);
	void box_small_struct(cell x, cell y, cell size);
	void box_medium_struct(cell x1, cell x2, cell x3, cell x4, cell size);

	//quotations
	inline void vmprim_jit_compile();
	inline void vmprim_array_to_quotation();
	inline void vmprim_quotation_xt();
	void set_quot_xt(quotation *quot, code_block *code);
	void jit_compile(cell quot_, bool relocating);
	void compile_all_words();
	fixnum quot_code_offset_to_scan(cell quot_, cell offset);
	cell lazy_jit_compile_impl(cell quot_, stack_frame *stack);
	inline void vmprim_quot_compiled_p();

	//dispatch
	cell search_lookup_alist(cell table, cell klass);
	cell search_lookup_hash(cell table, cell klass, cell hashcode);
	cell nth_superclass(tuple_layout *layout, fixnum echelon);
	cell nth_hashcode(tuple_layout *layout, fixnum echelon);
	cell lookup_tuple_method(cell obj, cell methods);
	cell lookup_hi_tag_method(cell obj, cell methods);
	cell lookup_hairy_method(cell obj, cell methods);
	cell lookup_method(cell obj, cell methods);
	inline void vmprim_lookup_method();
	cell object_class(cell obj);
	cell method_cache_hashcode(cell klass, array *array);
	void update_method_cache(cell cache, cell klass, cell method);
	inline void vmprim_mega_cache_miss();
	inline void vmprim_reset_dispatch_stats();
	inline void vmprim_dispatch_stats();

	//inline cache
	void init_inline_caching(int max_size);
	void deallocate_inline_cache(cell return_address);
	cell determine_inline_cache_type(array *cache_entries);
	void update_pic_count(cell type);
	code_block *compile_inline_cache(fixnum index,cell generic_word_,cell methods_,cell cache_entries_,bool tail_call_p);
	void *megamorphic_call_stub(cell generic_word);
	cell inline_cache_size(cell cache_entries);
	cell add_inline_cache_entry(cell cache_entries_, cell klass_, cell method_);
	void update_pic_transitions(cell pic_size);
	void *inline_cache_miss(cell return_address);
	inline void vmprim_reset_inline_cache_stats();
	inline void vmprim_inline_cache_stats();

	//factor
	void default_parameters(vm_parameters *p);
	bool factor_arg(const vm_char* str, const vm_char* arg, cell* value);
	void init_parameters_from_args(vm_parameters *p, int argc, vm_char **argv);
	void do_stage1_init();
	void init_factor(vm_parameters *p);
	void pass_args_to_factor(int argc, vm_char **argv);
	void start_factor(vm_parameters *p);
	void start_embedded_factor(vm_parameters *p);
	void start_standalone_factor(int argc, vm_char **argv);
	char *factor_eval_string(char *string);
	void factor_eval_free(char *result);
	void factor_yield();
	void factor_sleep(long us);

	// os-*
	inline void vmprim_existsp();
	void init_ffi();
	void ffi_dlopen(dll *dll);
	void *ffi_dlsym(dll *dll, symbol_char *symbol);
	void ffi_dlclose(dll *dll);
	segment *alloc_segment(cell size);
	void c_to_factor_toplevel(cell quot);

	// os-windows
  #if defined(WINDOWS)
	void sleep_micros(u64 usec);
	long getpagesize();
	void dealloc_segment(segment *block);
	const vm_char *vm_executable_path();
	const vm_char *default_image_path();
	void windows_image_path(vm_char *full_path, vm_char *temp_path, unsigned int length);
	bool windows_stat(vm_char *path);
	
   #if defined(WINNT)
	void open_console();
	LONG exception_handler(PEXCEPTION_POINTERS pe);
 	// next method here:	
   #endif
  #else  // UNIX
	void memory_signal_handler(int signal, siginfo_t *siginfo, void *uap);
	void misc_signal_handler(int signal, siginfo_t *siginfo, void *uap);
	void fpe_signal_handler(int signal, siginfo_t *siginfo, void *uap);
	stack_frame *uap_stack_pointer(void *uap);

  #endif

  #ifdef __APPLE__
	void call_fault_handler(exception_type_t exception, exception_data_type_t code, MACH_EXC_STATE_TYPE *exc_state, MACH_THREAD_STATE_TYPE *thread_state, MACH_FLOAT_STATE_TYPE *float_state);
  #endif
	
	void print_vm_data();
};


#ifndef FACTOR_REENTRANT
   #define FACTOR_SINGLE_THREADED_SINGLETON
#endif

#ifdef FACTOR_SINGLE_THREADED_SINGLETON
/* calls are dispatched using the singleton vm ptr */
  extern factorvm *vm;
  #define PRIMITIVE_GETVM() vm
  #define PRIMITIVE_OVERFLOW_GETVM() vm
  #define VM_PTR vm
  #define ASSERTVM() 
  #define SIGNAL_VM_PTR() vm
#endif

#ifdef FACTOR_SINGLE_THREADED_TESTING
/* calls are dispatched as per multithreaded, but checked against singleton */
  extern factorvm *vm;
  #define ASSERTVM() assert(vm==myvm)
  #define PRIMITIVE_GETVM() ((factorvm*)myvm)
  #define PRIMITIVE_OVERFLOW_GETVM() ASSERTVM(); myvm
  #define VM_PTR myvm
  #define SIGNAL_VM_PTR() tls_vm()
#endif

#ifdef FACTOR_REENTRANT_TLS
/* uses thread local storage to obtain vm ptr */
  #define PRIMITIVE_GETVM() tls_vm()
  #define PRIMITIVE_OVERFLOW_GETVM() tls_vm()
  #define VM_PTR tls_vm()
  #define ASSERTVM() 
  #define SIGNAL_VM_PTR() tls_vm()
#endif

#ifdef FACTOR_REENTRANT
  #define PRIMITIVE_GETVM() ((factorvm*)myvm)
  #define PRIMITIVE_OVERFLOW_GETVM() ((factorvm*)myvm)
  #define VM_PTR myvm
  #define ASSERTVM() 
  #define SIGNAL_VM_PTR() tls_vm()
#endif

}
