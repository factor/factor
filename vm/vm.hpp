namespace factor
{

struct heap;
struct data_heap;
struct data;
struct zone;
struct vm_parameters;
struct image_header;

typedef u8 card;
typedef u8 card_deck;

typedef void (*heap_iterator)(heap_block *compiled);
typedef void (*code_heap_iterator)(code_block *compiled);

struct factorvm {

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
	void fatal_error(const char* msg, cell tagged);
	void critical_error(const char* msg, cell tagged);
	void throw_error(cell error, stack_frame *callstack_top);
	void not_implemented_error();
	bool in_page(cell fault, cell area, cell area_size, int offset);
	void memory_protection_error(cell addr, stack_frame *native_stack);
	void signal_error(int signal, stack_frame *native_stack);
	void divide_by_zero_error();
	void fp_trap_error(stack_frame *signal_callstack_top);
	inline void vmprim_call_clear();
	inline void vmprim_unimplemented();
	void memory_signal_handler_impl();
	void misc_signal_handler_impl();
	void fp_signal_handler_impl();
	void type_error(cell type, cell tagged);
	void general_error(vm_error_type error, cell arg1, cell arg2, stack_frame *callstack_top);

	// bignum
	int bignum_equal_p(bignum * x, bignum * y);
	enum bignum_comparison bignum_compare(bignum * x, bignum * y);
	bignum *bignum_add(bignum * x, bignum * y);
	bignum *bignum_subtract(bignum * x, bignum * y);
	bignum *bignum_multiply(bignum * x, bignum * y);
	void bignum_divide(bignum * numerator, bignum * denominator, bignum * * quotient, bignum * * remainder);
	bignum *bignum_quotient(bignum * numerator, bignum * denominator);
	bignum *bignum_remainder(bignum * numerator, bignum * denominator);
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
	bignum *digit_stream_to_bignum(unsigned int n_digits, unsigned int (*producer)(unsigned int), unsigned int radix, int negative_p);

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

	// local roots
	std::vector<cell> gc_locals;
	std::vector<cell> gc_bignums;

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
	void overflow_fixnum_add(fixnum x, fixnum y);
	void overflow_fixnum_subtract(fixnum x, fixnum y);
	void overflow_fixnum_multiply(fixnum x, fixnum y);
	inline cell allot_integer(fixnum x);
	inline cell allot_cell(cell x);
	inline cell allot_float(double n);
	inline bignum *float_to_bignum(cell tagged);
	inline double bignum_to_float(cell tagged);
	
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
	int err_no();
	void clear_err_no();

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

	//utilities
	void *safe_malloc(size_t size);
	vm_char *safe_strdup(const vm_char *str);
	void nl();
	void print_string(const char *str);
	void print_cell(cell x);
	void print_cell_hex(cell x);
	void print_cell_hex_pad(cell x);
	void print_fixnum(fixnum x);
	cell read_cell_hex();





};

extern factorvm *vm;


// write_barrier.hpp

inline card *factorvm::addr_to_card(cell a)
{
	return (card*)(((cell)(a) >> card_bits) + cards_offset);
}

inline card *addr_to_card(cell a)
{
	return vm->addr_to_card(a);
}

inline cell factorvm::card_to_addr(card *c)
{
	return ((cell)c - cards_offset) << card_bits;
}

inline cell card_to_addr(card *c)
{
	return vm->card_to_addr(c);
}

inline cell factorvm::card_offset(card *c)
{
	return *(c - (cell)data->cards + (cell)data->allot_markers);
}

inline cell card_offset(card *c)
{
	return vm->card_offset(c);
}

inline card_deck *factorvm::addr_to_deck(cell a)
{
	return (card_deck *)(((cell)a >> deck_bits) + decks_offset);
}

inline card_deck *addr_to_deck(cell a)
{
	return vm->addr_to_deck(a);
}

inline cell factorvm::deck_to_addr(card_deck *c)
{
	return ((cell)c - decks_offset) << deck_bits;
}

inline cell deck_to_addr(card_deck *c)
{
	return vm->deck_to_addr(c);
}

inline card *factorvm::deck_to_card(card_deck *d)
{
	return (card *)((((cell)d - decks_offset) << (deck_bits - card_bits)) + cards_offset);
}

inline card *deck_to_card(card_deck *d)
{
	return vm->deck_to_card(d);
}

inline card *factorvm::addr_to_allot_marker(object *a)
{
	return (card *)(((cell)a >> card_bits) + allot_markers_offset);
}

inline card *addr_to_allot_marker(object *a)
{
	return vm->addr_to_allot_marker(a);
}

/* the write barrier must be called any time we are potentially storing a
pointer from an older generation to a younger one */
inline void factorvm::write_barrier(object *obj)
{
	*addr_to_card((cell)obj) = card_mark_mask;
	*addr_to_deck((cell)obj) = card_mark_mask;
}

inline void write_barrier(object *obj)
{
	return vm->write_barrier(obj);
}

/* we need to remember the first object allocated in the card */
inline void factorvm::allot_barrier(object *address)
{
	card *ptr = addr_to_allot_marker(address);
	if(*ptr == invalid_allot_marker)
		*ptr = ((cell)address & addr_card_mask);
}

inline void allot_barrier(object *address)
{
	return vm->allot_barrier(address);
}


//data_gc.hpp
inline bool factorvm::collecting_accumulation_gen_p()
{
	return ((data->have_aging_p()
		&& collecting_gen == data->aging()
		&& !collecting_aging_again)
		|| collecting_gen == data->tenured());
}

inline bool collecting_accumulation_gen_p()
{
	return vm->collecting_accumulation_gen_p();
}

inline object *factorvm::allot_zone(zone *z, cell a)
{
	cell h = z->here;
	z->here = h + align8(a);
	object *obj = (object *)h;
	allot_barrier(obj);
	return obj;
}

inline object *allot_zone(zone *z, cell a)
{
	return vm->allot_zone(z,a);
}

/*
 * It is up to the caller to fill in the object's fields in a meaningful
 * fashion!
 */
inline object *factorvm::allot_object(header header, cell size)
{
#ifdef GC_DEBUG
	if(!gc_off)
		gc();
#endif

	object *obj;

	if(nursery.size - allot_buffer_zone > size)
	{
		/* If there is insufficient room, collect the nursery */
		if(nursery.here + allot_buffer_zone + size > nursery.end)
			garbage_collection(data->nursery(),false,0);

		cell h = nursery.here;
		nursery.here = h + align8(size);
		obj = (object *)h;
	}
	/* If the object is bigger than the nursery, allocate it in
	tenured space */
	else
	{
		zone *tenured = &data->generations[data->tenured()];

		/* If tenured space does not have enough room, collect */
		if(tenured->here + size > tenured->end)
		{
			gc();
			tenured = &data->generations[data->tenured()];
		}

		/* If it still won't fit, grow the heap */
		if(tenured->here + size > tenured->end)
		{
			garbage_collection(data->tenured(),true,size);
			tenured = &data->generations[data->tenured()];
		}

		obj = allot_zone(tenured,size);

		/* Allows initialization code to store old->new pointers
		without hitting the write barrier in the common case of
		a nursery allocation */
		write_barrier(obj);
	}

	obj->h = header;
	return obj;
}

inline object *allot_object(header header, cell size)
{
	return vm->allot_object(header,size);
}

template<typename TYPE> TYPE *factorvm::allot(cell size)
{
	return (TYPE *)allot_object(header(TYPE::type_number),size);
}

template<typename TYPE> TYPE *allot(cell size)
{
	return vm->allot<TYPE>(size);
}

inline void factorvm::check_data_pointer(object *pointer)
{
#ifdef FACTOR_DEBUG
	if(!growing_data_heap)
	{
		assert((cell)pointer >= data->seg->start
		       && (cell)pointer < data->seg->end);
	}
#endif
}

inline void check_data_pointer(object *pointer)
{
	return vm->check_data_pointer(pointer);
}

inline void factorvm::check_tagged_pointer(cell tagged)
{
#ifdef FACTOR_DEBUG
	if(!immediate_p(tagged))
	{
		object *obj = untag<object>(tagged);
		check_data_pointer(obj);
		obj->h.hi_tag();
	}
#endif
}

inline void check_tagged_pointer(cell tagged)
{
	return vm->check_tagged_pointer(tagged);
}

//local_roots.hpp
template <typename TYPE>
struct gc_root : public tagged<TYPE>
{
	factorvm *myvm;

	void push() { check_tagged_pointer(tagged<TYPE>::value()); myvm->gc_locals.push_back((cell)this); }
	
	//explicit gc_root(cell value_, factorvm *vm) : myvm(vm),tagged<TYPE>(value_) { push(); }
	explicit gc_root(cell value_,factorvm *vm) : tagged<TYPE>(value_),myvm(vm) { push(); }
	explicit gc_root(TYPE *value_, factorvm *vm) : tagged<TYPE>(value_),myvm(vm) { push(); }

	const gc_root<TYPE>& operator=(const TYPE *x) { tagged<TYPE>::operator=(x); return *this; }
	const gc_root<TYPE>& operator=(const cell &x) { tagged<TYPE>::operator=(x); return *this; }

	~gc_root() {
#ifdef FACTOR_DEBUG
		assert(myvm->gc_locals.back() == (cell)this);
#endif
		myvm->gc_locals.pop_back();
	}
};

/* A similar hack for the bignum implementation */
struct gc_bignum
{
	bignum **addr;
	factorvm *myvm;
	gc_bignum(bignum **addr_, factorvm *vm) : addr(addr_), myvm(vm) {
		if(*addr_)
			check_data_pointer(*addr_);
		myvm->gc_bignums.push_back((cell)addr);
	}

	~gc_bignum() {
#ifdef FACTOR_DEBUG
		assert(myvm->gc_bignums.back() == (cell)addr);
#endif
		myvm->gc_bignums.pop_back();
	}
};

#define GC_BIGNUM(x,vm) gc_bignum x##__gc_root(&x,vm)

//generic_arrays.hpp
template <typename T> T *factorvm::allot_array_internal(cell capacity)
{
	T *array = allot<T>(array_size<T>(capacity));
	array->capacity = tag_fixnum(capacity);
	return array;
}

template <typename T> T *allot_array_internal(cell capacity)
{
	return vm->allot_array_internal<T>(capacity);
}

template <typename T> bool factorvm::reallot_array_in_place_p(T *array, cell capacity)
{
	return in_zone(&nursery,array) && capacity <= array_capacity(array);
}

template <typename T> bool reallot_array_in_place_p(T *array, cell capacity)
{
	return vm->reallot_array_in_place_p<T>(array,capacity);
}

template <typename TYPE> TYPE *factorvm::reallot_array(TYPE *array_, cell capacity)
{
	gc_root<TYPE> array(array_,this);

	if(reallot_array_in_place_p(array.untagged(),capacity))
	{
		array->capacity = tag_fixnum(capacity);
		return array.untagged();
	}
	else
	{
		cell to_copy = array_capacity(array.untagged());
		if(capacity < to_copy)
			to_copy = capacity;

		TYPE *new_array = allot_array_internal<TYPE>(capacity);
	
		memcpy(new_array + 1,array.untagged() + 1,to_copy * TYPE::element_size);
		memset((char *)(new_array + 1) + to_copy * TYPE::element_size,
			0,(capacity - to_copy) * TYPE::element_size);

		return new_array;
	}
}

//arrays.hpp
inline void factorvm::set_array_nth(array *array, cell slot, cell value)
{
#ifdef FACTOR_DEBUG
	assert(slot < array_capacity(array));
	assert(array->h.hi_tag() == ARRAY_TYPE);
	check_tagged_pointer(value);
#endif
	array->data()[slot] = value;
	write_barrier(array);
}

inline void set_array_nth(array *array, cell slot, cell value)
{
	return vm->set_array_nth(array,slot,value);
}

struct growable_array {
	cell count;
	gc_root<array> elements;

	growable_array(factorvm *myvm, cell capacity = 10) : count(0), elements(allot_array(capacity,F),myvm) {}

	void add(cell elt);
	void trim();
};

//byte_arrays.hpp
struct growable_byte_array {
	cell count;
	gc_root<byte_array> elements;

	growable_byte_array(factorvm *vm,cell capacity = 40) : count(0), elements(allot_byte_array(capacity),vm) { }

	void append_bytes(void *elts, cell len);
	void append_byte_array(cell elts);

	void trim();
};

//math.hpp
inline cell factorvm::allot_integer(fixnum x)
{
	if(x < fixnum_min || x > fixnum_max)
		return tag<bignum>(fixnum_to_bignum(x));
	else
		return tag_fixnum(x);
}

inline cell allot_integer(fixnum x)
{
	return vm->allot_integer(x);
}

inline cell factorvm::allot_cell(cell x)
{
	if(x > (cell)fixnum_max)
		return tag<bignum>(cell_to_bignum(x));
	else
		return tag_fixnum(x);
}

inline cell allot_cell(cell x)
{
	return vm->allot_cell(x);
}

inline cell factorvm::allot_float(double n)
{
	boxed_float *flo = allot<boxed_float>(sizeof(boxed_float));
	flo->n = n;
	return tag(flo);
}

inline cell allot_float(double n)
{
	return vm->allot_float(n);
}

inline bignum *factorvm::float_to_bignum(cell tagged)
{
	return double_to_bignum(untag_float(tagged));
}

inline bignum *float_to_bignum(cell tagged)
{
	return vm->float_to_bignum(tagged);
}

inline double factorvm::bignum_to_float(cell tagged)
{
	return bignum_to_double(untag<bignum>(tagged));
}

inline double bignum_to_float(cell tagged)
{
	return vm->bignum_to_float(tagged);
}

// next method here:


}
