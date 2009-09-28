namespace factor
{

struct factor_vm 
{
	// First five fields accessed directly by assembler. See vm.factor
	context *stack_chain; 
	zone nursery; /* new objects are allocated here */
	cell cards_offset;
	cell decks_offset;
	cell userenv[USER_ENV]; /* TAGGED user environment data; see getenv/setenv prims */

	// contexts
	cell ds_size, rs_size;
	context *unused_contexts;

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
	void primitive_datastack();
	void primitive_retainstack();
	void primitive_set_datastack();
	void primitive_set_retainstack();
	void primitive_check_datastack();

	// run
	cell T;  /* Canonical T object. It's just a word */

	void primitive_getenv();
	void primitive_setenv();
	void primitive_exit();
	void primitive_micros();
	void primitive_sleep();
	void primitive_set_slot();
	void primitive_load_locals();
	cell clone_object(cell obj_);
	void primitive_clone();

	// profiler
	bool profiling_p;

	void init_profiler();
	code_block *compile_profiling_stub(cell word_);
	void set_profiling(bool profiling);
	void primitive_profiling();

	// errors
	/* Global variables used to pass fault handler state from signal handler to
	   user-space */
	cell signal_number;
	cell signal_fault_addr;
	unsigned int signal_fpu_status;
	stack_frame *signal_callstack_top;

	void out_of_memory();
	void critical_error(const char* msg, cell tagged);
	void throw_error(cell error, stack_frame *callstack_top);
	void not_implemented_error();
	bool in_page(cell fault, cell area, cell area_size, int offset);
	void memory_protection_error(cell addr, stack_frame *native_stack);
	void signal_error(int signal, stack_frame *native_stack);
	void divide_by_zero_error();
	void fp_trap_error(unsigned int fpu_status, stack_frame *signal_callstack_top);
	void primitive_call_clear();
	void primitive_unimplemented();
	void memory_signal_handler_impl();
	void misc_signal_handler_impl();
	void fp_signal_handler_impl();
	void type_error(cell type, cell tagged);
	void general_error(vm_error_type error, cell arg1, cell arg2, stack_frame *native_stack);

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
	bignum *digit_stream_to_bignum(unsigned int n_digits, unsigned int (*producer)(unsigned int, factor_vm *), unsigned int radix, int negative_p);

	//data_heap
	bool secure_gc;  /* Set by the -securegc command line argument */
	bool gc_off; /* GC is off during heap walking */
	data_heap *data;
	/* A heap walk allows useful things to be done, like finding all
	   references to an object for debugging purposes. */
	cell heap_scan_ptr;

	void init_card_decks();
	data_heap *grow_data_heap(data_heap *data, cell requested_bytes);
	void clear_cards(cell from, cell to);
	void clear_decks(cell from, cell to);
	void clear_allot_markers(cell from, cell to);
	void reset_generation(cell i);
	void reset_generations(cell from, cell to);
	void set_data_heap(data_heap *data_);
	void init_data_heap(cell gens,cell young_size,cell aging_size,cell tenured_size,bool secure_gc_);
	cell untagged_object_size(object *pointer);
	cell unaligned_object_size(object *pointer);
	void primitive_size();
	cell binary_payload_start(object *pointer);
	void primitive_data_room();
	void begin_scan();
	void end_scan();
	void primitive_begin_scan();
	cell next_object();
	void primitive_next_object();
	void primitive_end_scan();
	template<typename T> void each_object(T &functor);
	cell find_all_words();
	cell object_size(cell tagged);

	
	//write barrier
	cell allot_markers_offset;

	inline card *addr_to_card(cell a)
	{
		return (card*)(((cell)(a) >> card_bits) + cards_offset);
	}

	inline cell card_to_addr(card *c)
	{
		return ((cell)c - cards_offset) << card_bits;
	}
	
	inline cell card_offset(card *c)
	{
		return *(c - (cell)data->cards + (cell)data->allot_markers);
	}
	
	inline card_deck *addr_to_deck(cell a)
	{
		return (card_deck *)(((cell)a >> deck_bits) + decks_offset);
	}
	
	inline cell deck_to_addr(card_deck *c)
	{
		return ((cell)c - decks_offset) << deck_bits;
	}
	
	inline card *deck_to_card(card_deck *d)
	{
		return (card *)((((cell)d - decks_offset) << (deck_bits - card_bits)) + cards_offset);
	}
	
	inline card *addr_to_allot_marker(object *a)
	{
		return (card *)(((cell)a >> card_bits) + allot_markers_offset);
	}

	/* the write barrier must be called any time we are potentially storing a
	   pointer from an older generation to a younger one */
	inline void write_barrier(object *obj)
	{
		*addr_to_card((cell)obj) = card_mark_mask;
		*addr_to_deck((cell)obj) = card_mark_mask;
	}

	/* we need to remember the first object allocated in the card */
	inline void allot_barrier(object *address)
	{
		card *ptr = addr_to_allot_marker(address);
		if(*ptr == invalid_allot_marker)
			*ptr = ((cell)address & addr_card_mask);
	}

	// data_gc
	/* used during garbage collection only */
	zone *newspace;
	bool performing_gc;
	bool performing_compaction;
	cell collecting_gen;
	/* if true, we are collecting aging space for the second time, so if it is still
	   full, we go on to collect tenured */
	bool collecting_aging_again;
	/* in case a generation fills up in the middle of a gc, we jump back
	   up to try collecting the next generation. */
	jmp_buf gc_jmp;
	gc_stats stats[max_gen_count];
	u64 cards_scanned;
	u64 decks_scanned;
	u64 card_scan_time;
	cell code_heap_scans;
	/* What generation was being collected when copy_code_heap_roots() was last
	   called? Until the next call to add_code_block(), future
	   collections of younger generations don't have to touch the code
	   heap. */
	cell last_code_heap_scan;
	/* sometimes we grow the heap */
	bool growing_data_heap;
	data_heap *old_data_heap;

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
	void primitive_gc();
	void primitive_gc_stats();
	void clear_gc_stats();
	void primitive_become();
	void inline_gc(cell *gc_roots_base, cell gc_roots_size);
	inline bool collecting_accumulation_gen_p();
	inline object *allot_zone(zone *z, cell a);
	inline object *allot_object(header header, cell size);
	template <typename TYPE> TYPE *allot(cell size);
	inline void check_data_pointer(object *pointer);
	inline void check_tagged_pointer(cell tagged);
	void primitive_clear_gc_stats();

	// local roots
	/* If a runtime function needs to call another function which potentially
	   allocates memory, it must wrap any local variable references to Factor
	   objects in gc_root instances */
	std::vector<cell> gc_locals;
	std::vector<cell> gc_bignums;

	// generic arrays
	template <typename T> T *allot_array_internal(cell capacity);
	template <typename T> bool reallot_array_in_place_p(T *array, cell capacity);
	template <typename TYPE> TYPE *reallot_array(TYPE *array_, cell capacity);

	//debug
	bool fep_disabled;
	bool full_output;
	cell look_for;
	cell obj;

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
	void primitive_die();

	//arrays
	array *allot_array(cell capacity, cell fill_);
	void primitive_array();
	cell allot_array_1(cell obj_);
	cell allot_array_2(cell v1_, cell v2_);
	cell allot_array_4(cell v1_, cell v2_, cell v3_, cell v4_);
	void primitive_resize_array();
	inline void set_array_nth(array *array, cell slot, cell value);

	//strings
	cell string_nth(string* str, cell index);
	void set_string_nth_fast(string *str, cell index, cell ch);
	void set_string_nth_slow(string *str_, cell index, cell ch);
	void set_string_nth(string *str, cell index, cell ch);
	string *allot_string_internal(cell capacity);
	void fill_string(string *str_, cell start, cell capacity, cell fill);
	string *allot_string(cell capacity, cell fill);
	void primitive_string();
	bool reallot_string_in_place_p(string *str, cell capacity);
	string* reallot_string(string *str_, cell capacity);
	void primitive_resize_string();
	void primitive_string_nth();
	void primitive_set_string_nth_fast();
	void primitive_set_string_nth_slow();

	//booleans
	void box_boolean(bool value);
	bool to_boolean(cell value);
	inline cell tag_boolean(cell untagged);

	//byte arrays
	byte_array *allot_byte_array(cell size);
	void primitive_byte_array();
	void primitive_uninitialized_byte_array();
	void primitive_resize_byte_array();

	//tuples
	tuple *allot_tuple(cell layout_);
	void primitive_tuple();
	void primitive_tuple_boa();

	//words
	word *allot_word(cell name_, cell vocab_, cell hashcode_);
	void primitive_word();
	void primitive_word_xt();
	void update_word_xt(cell w_);
	void primitive_optimized_p();
	void primitive_wrapper();

	//math
	cell bignum_zero;
	cell bignum_pos_one;
	cell bignum_neg_one;	

	void primitive_bignum_to_fixnum();
	void primitive_float_to_fixnum();
	void primitive_fixnum_divint();
	void primitive_fixnum_divmod();
	bignum *fixnum_to_bignum(fixnum);
	bignum *cell_to_bignum(cell);
	bignum *long_long_to_bignum(s64 n);
	bignum *ulong_long_to_bignum(u64 n);
	inline fixnum sign_mask(fixnum x);
	inline fixnum branchless_max(fixnum x, fixnum y);
	inline fixnum branchless_abs(fixnum x);
	void primitive_fixnum_shift();
	void primitive_fixnum_to_bignum();
	void primitive_float_to_bignum();
	void primitive_bignum_eq();
	void primitive_bignum_add();
	void primitive_bignum_subtract();
	void primitive_bignum_multiply();
	void primitive_bignum_divint();
	void primitive_bignum_divmod();
	void primitive_bignum_mod();
	void primitive_bignum_and();
	void primitive_bignum_or();
	void primitive_bignum_xor();
	void primitive_bignum_shift();
	void primitive_bignum_less();
	void primitive_bignum_lesseq();
	void primitive_bignum_greater();
	void primitive_bignum_greatereq();
	void primitive_bignum_not();
	void primitive_bignum_bitp();
	void primitive_bignum_log2();
	unsigned int bignum_producer(unsigned int digit);
	void primitive_byte_array_to_bignum();
	cell unbox_array_size();
	void primitive_fixnum_to_float();
	void primitive_bignum_to_float();
	void primitive_str_to_float();
	void primitive_float_to_str();
	void primitive_float_eq();
	void primitive_float_add();
	void primitive_float_subtract();
	void primitive_float_multiply();
	void primitive_float_divfloat();
	void primitive_float_mod();
	void primitive_float_less();
	void primitive_float_lesseq();
	void primitive_float_greater();
	void primitive_float_greatereq();
	void primitive_float_bits();
	void primitive_bits_float();
	void primitive_double_bits();
	void primitive_bits_double();
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
	void primitive_fopen();
	void primitive_fgetc();
	void primitive_fread();
	void primitive_fputc();
	void primitive_fwrite();
	void primitive_fseek();
	void primitive_fflush();
	void primitive_fclose();

	//code_block
	typedef void (factor_vm::*relocation_iterator)(relocation_entry rel, cell index, code_block *compiled);

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
	heap *code;
	unordered_map<heap_block *, char *> forwarding;
	typedef void (factor_vm::*code_heap_iterator)(code_block *compiled);

	void init_code_heap(cell size);
	bool in_code_heap_p(cell ptr);
	void jit_compile_word(cell word_, cell def_, bool relocate);
	void iterate_code_heap(code_heap_iterator iter);
	void copy_code_heap_roots();
	void update_code_heap_words();
	void primitive_modify_code_heap();
	void primitive_code_room();
	code_block *forward_xt(code_block *compiled);
	void forward_frame_xt(stack_frame *frame);
	void forward_object_xts();
	void fixup_object_xts();
	void compact_code_heap();
	inline void check_code_pointer(cell ptr);

	//image
	cell code_relocation_base;
	cell data_relocation_base;

	void init_objects(image_header *h);
	void load_data_heap(FILE *file, image_header *h, vm_parameters *p);
	void load_code_heap(FILE *file, image_header *h, vm_parameters *p);
	bool save_image(const vm_char *filename);
	void primitive_save_image();
	void primitive_save_image_and_exit();
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
	void primitive_callstack();
	void primitive_set_callstack();
	code_block *frame_code(stack_frame *frame);
	cell frame_type(stack_frame *frame);
	cell frame_executing(stack_frame *frame);
	stack_frame *frame_successor(stack_frame *frame);
	cell frame_scan(stack_frame *frame);
	void primitive_callstack_to_array();
	stack_frame *innermost_stack_frame(callstack *stack);
	stack_frame *innermost_stack_frame_quot(callstack *callstack);
	void primitive_innermost_stack_frame_executing();
	void primitive_innermost_stack_frame_scan();
	void primitive_set_innermost_stack_frame_quot();
	void save_callstack_bottom(stack_frame *callstack_bottom);
	template<typename T> void iterate_callstack(cell top, cell bottom, T &iterator);
	inline void do_slots(cell obj, void (* iter)(cell *,factor_vm*));

	//alien
	char *pinned_alien_offset(cell obj);
	cell allot_alien(cell delegate_, cell displacement);
	void primitive_displaced_alien();
	void primitive_alien_address();
	void *alien_pointer();
	void primitive_dlopen();
	void primitive_dlsym();
	void primitive_dlclose();
	void primitive_dll_validp();
	void primitive_vm_ptr();
	char *alien_offset(cell obj);
	char *unbox_alien();
	void box_alien(void *ptr);
	void to_value_struct(cell src, void *dest, cell size);
	void box_value_struct(void *src, cell size);
	void box_small_struct(cell x, cell y, cell size);
	void box_medium_struct(cell x1, cell x2, cell x3, cell x4, cell size);

	//quotations
	void primitive_jit_compile();
	void primitive_array_to_quotation();
	void primitive_quotation_xt();
	void set_quot_xt(quotation *quot, code_block *code);
	void jit_compile(cell quot_, bool relocating);
	void compile_all_words();
	fixnum quot_code_offset_to_scan(cell quot_, cell offset);
	cell lazy_jit_compile_impl(cell quot_, stack_frame *stack);
	void primitive_quot_compiled_p();

	//dispatch
	cell megamorphic_cache_hits;
	cell megamorphic_cache_misses;

	cell search_lookup_alist(cell table, cell klass);
	cell search_lookup_hash(cell table, cell klass, cell hashcode);
	cell nth_superclass(tuple_layout *layout, fixnum echelon);
	cell nth_hashcode(tuple_layout *layout, fixnum echelon);
	cell lookup_tuple_method(cell obj, cell methods);
	cell lookup_hi_tag_method(cell obj, cell methods);
	cell lookup_hairy_method(cell obj, cell methods);
	cell lookup_method(cell obj, cell methods);
	void primitive_lookup_method();
	cell object_class(cell obj);
	cell method_cache_hashcode(cell klass, array *array);
	void update_method_cache(cell cache, cell klass, cell method);
	void primitive_mega_cache_miss();
	void primitive_reset_dispatch_stats();
	void primitive_dispatch_stats();

	//inline cache
	cell max_pic_size;
	cell cold_call_to_ic_transitions;
	cell ic_to_pic_transitions;
	cell pic_to_mega_transitions;
	cell pic_counts[4];  /* PIC_TAG, PIC_HI_TAG, PIC_TUPLE, PIC_HI_TAG_TUPLE */

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
	void primitive_reset_inline_cache_stats();
	void primitive_inline_cache_stats();

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
	void primitive_existsp();
	void init_ffi();
	void ffi_dlopen(dll *dll);
	void *ffi_dlsym(dll *dll, symbol_char *symbol);
	void ffi_dlclose(dll *dll);
	void c_to_factor_toplevel(cell quot);

	// os-windows
  #if defined(WINDOWS)
	void sleep_micros(u64 usec);
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
	
	factor_vm() 
		: profiling_p(false),
		  secure_gc(false),
		  gc_off(false),
		  performing_gc(false),
		  performing_compaction(false),
		  collecting_aging_again(false),
		  growing_data_heap(false),
		  fep_disabled(false),
		  full_output(false),
		  max_pic_size(0)
	{
		memset(this,0,sizeof(this)); // just to make sure
	}

};

#ifndef FACTOR_REENTRANT
   #define FACTOR_SINGLE_THREADED_SINGLETON
#endif

#ifdef FACTOR_SINGLE_THREADED_SINGLETON
/* calls are dispatched using the singleton vm ptr */
  extern factor_vm *vm;
  #define PRIMITIVE_GETVM() vm
  #define PRIMITIVE_OVERFLOW_GETVM() vm
  #define VM_PTR vm
  #define ASSERTVM() 
  #define SIGNAL_VM_PTR() vm
#endif

#ifdef FACTOR_SINGLE_THREADED_TESTING
/* calls are dispatched as per multithreaded, but checked against singleton */
  extern factor_vm *vm;
  #define ASSERTVM() assert(vm==myvm)
  #define PRIMITIVE_GETVM() ((factor_vm*)myvm)
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
  #define PRIMITIVE_GETVM() ((factor_vm*)myvm)
  #define PRIMITIVE_OVERFLOW_GETVM() ((factor_vm*)myvm)
  #define VM_PTR myvm
  #define ASSERTVM() 
  #define SIGNAL_VM_PTR() tls_vm()
#endif

}
