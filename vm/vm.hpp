namespace factor
{

struct growable_array;
struct code_root;

struct factor_vm
{
	// First 5 fields accessed directly by compiler. See basis/vm/vm.factor

	/* Current context */
	context *ctx;

	/* Spare context -- for callbacks */
	context *spare_ctx;

	/* New objects are allocated here */
	nursery_space nursery;

	/* Add this to a shifted address to compute write barrier offsets */
	cell cards_offset;
	cell decks_offset;

	/* Various special objects, accessed by special-object and
	set-special-object primitives */
	cell special_objects[special_object_count];

	/* Data stack and retain stack sizes */
	cell datastack_size, retainstack_size, callstack_size;

	/* Stack of callback IDs */
	std::vector<int> callback_ids;

	/* Next callback ID */
	int callback_id;

	/* Pooling unused contexts to make context allocation cheaper */
	std::vector<context *> unused_contexts;

	/* Active contexts, for tracing by the GC */
	std::set<context *> active_contexts;

	/* Canonical truth value. In Factor, 't' */
	cell true_object;

	/* External entry points */
	c_to_factor_func_type c_to_factor_func;

	/* Is call counting enabled? */
	bool profiling_p;

	/* Global variables used to pass fault handler state from signal handler to
	   user-space */
	cell signal_number;
	cell signal_fault_addr;
	unsigned int signal_fpu_status;
	stack_frame *signal_callstack_top;

	/* GC is off during heap walking */
	bool gc_off;

	/* Data heap */
	data_heap *data;

	/* Code heap */
	code_heap *code;

	/* Pinned callback stubs */
	callback_heap *callbacks;

	/* Only set if we're performing a GC */
	gc_state *current_gc;

	/* Mark stack */
	std::vector<cell> mark_stack;

	/* If not NULL, we push GC events here */
	std::vector<gc_event> *gc_events;

	/* If a runtime function needs to call another function which potentially
	   allocates memory, it must wrap any references to the data and code
	   heaps with data_root and code_root smart pointers, which register
	   themselves here. See data_roots.hpp and code_roots.hpp */
	std::vector<data_root_range> data_roots;
	std::vector<cell> bignum_roots;
	std::vector<code_root *> code_roots;

	/* Debugger */
	bool fep_disabled;
	bool full_output;

	/* Canonical bignums */
	cell bignum_zero;
	cell bignum_pos_one;
	cell bignum_neg_one;

	/* Method dispatch statistics */
	dispatch_statistics dispatch_stats;

	/* Number of entries in a polymorphic inline cache */
	cell max_pic_size;

	/* Incrementing object counter for identity hashing */
	cell object_counter;

	/* Sanity check to ensure that monotonic counter doesn't
	decrease */
	u64 last_nano_count;

	/* Stack for signal handlers, only used on Unix */
	segment *signal_callstack_seg;

	// contexts
	context *new_context();
	void init_context(context *ctx);
	void delete_context(context *old_context);
	void init_contexts(cell datastack_size_, cell retainstack_size_, cell callstack_size_);
	void delete_contexts();
	cell begin_callback(cell quot);
	void end_callback();
	void primitive_current_callback();
	void primitive_context_object();
	void primitive_context_object_for();
	void primitive_set_context_object();
	cell stack_to_array(cell bottom, cell top);
	cell datastack_to_array(context *ctx);
	void primitive_datastack();
	void primitive_datastack_for();
	cell retainstack_to_array(context *ctx);
	void primitive_retainstack();
	void primitive_retainstack_for();
	cell array_to_stack(array *array, cell bottom);
	void set_datastack(context *ctx, array *array);
	void primitive_set_datastack();
	void set_retainstack(context *ctx, array *array);
	void primitive_set_retainstack();
	void primitive_check_datastack();
	void primitive_load_locals();

	template<typename Iterator> void iterate_active_callstacks(Iterator &iter)
	{
		std::set<context *>::const_iterator begin = active_contexts.begin();
		std::set<context *>::const_iterator end = active_contexts.end();
		while(begin != end) iterate_callstack(*begin++,iter);
	}

	// run
	void primitive_exit();
	void primitive_system_micros();
	void primitive_nano_count();
	void primitive_sleep();
	void primitive_set_slot();

	// objects
	void primitive_special_object();
	void primitive_set_special_object();
	void primitive_identity_hashcode();
	void compute_identity_hashcode(object *obj);
	void primitive_compute_identity_hashcode();
	cell object_size(cell tagged);
	cell clone_object(cell obj_);
	void primitive_clone();
	void primitive_become();

	// profiler
	void init_profiler();
	code_block *compile_profiling_stub(cell word_);
	void set_profiling(bool profiling);
	void primitive_profiling();

	// errors
	void throw_error(cell error, stack_frame *stack);
	void general_error(vm_error_type error, cell arg1, cell arg2, stack_frame *stack);
	void general_error(vm_error_type error, cell arg1, cell arg2);
	void type_error(cell type, cell tagged);
	void not_implemented_error();
	void memory_protection_error(cell addr, stack_frame *stack);
	void signal_error(cell signal, stack_frame *stack);
	void divide_by_zero_error();
	void fp_trap_error(unsigned int fpu_status, stack_frame *stack);
	void primitive_unimplemented();
	void memory_signal_handler_impl();
	void misc_signal_handler_impl();
	void fp_signal_handler_impl();

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

	//data heap
	void init_card_decks();
	void set_data_heap(data_heap *data_);
	void init_data_heap(cell young_size, cell aging_size, cell tenured_size);
	void primitive_size();
	data_heap_room data_room();
	void primitive_data_room();
	void begin_scan();
	void end_scan();
	cell instances(cell type);
	void primitive_all_instances();

	template<typename Generation, typename Iterator>
	inline void each_object(Generation *gen, Iterator &iterator)
	{
		cell obj = gen->first_object();
		while(obj)
		{
			iterator((object *)obj);
			obj = gen->next_object_after(obj);
		}
	}

	template<typename Iterator> inline void each_object(Iterator &iterator)
	{
		gc_off = true;

		each_object(data->tenured,iterator);
		each_object(data->aging,iterator);
		each_object(data->nursery,iterator);

		gc_off = false;
	}

	/* the write barrier must be called any time we are potentially storing a
	   pointer from an older generation to a younger one */
	inline void write_barrier(cell *slot_ptr)
	{
		*(char *)(cards_offset + ((cell)slot_ptr >> card_bits)) = card_mark_mask;
		*(char *)(decks_offset + ((cell)slot_ptr >> deck_bits)) = card_mark_mask;
	}

	inline void write_barrier(object *obj, cell size)
	{
		cell start = (cell)obj & (~card_size + 1);
		cell end = ((cell)obj + size + card_size - 1) & (~card_size + 1);

		for(cell offset = start; offset < end; offset += card_size)
			write_barrier((cell *)offset);
	}

	// data heap checker
	void check_data_heap();

	// gc
	void end_gc();
	void start_gc_again();
	void update_code_heap_for_minor_gc(std::set<code_block *> *remembered_set);
	void collect_nursery();
	void collect_aging();
	void collect_to_tenured();
	void update_code_roots_for_sweep();
	void update_code_roots_for_compaction();
	void collect_mark_impl(bool trace_contexts_p);
	void collect_sweep_impl();
	void collect_full(bool trace_contexts_p);
	void collect_compact_impl(bool trace_contexts_p);
	void collect_compact_code_impl(bool trace_contexts_p);
	void collect_compact(bool trace_contexts_p);
	void collect_growing_heap(cell requested_bytes, bool trace_contexts_p);
	void gc(gc_op op, cell requested_bytes, bool trace_contexts_p);
	void primitive_minor_gc();
	void primitive_full_gc();
	void primitive_compact_gc();
	void inline_gc(cell *data_roots_base, cell data_roots_size);
	void primitive_enable_gc_events();
	void primitive_disable_gc_events();
	object *allot_object(cell type, cell size);
	object *allot_large_object(cell type, cell size);

	template<typename Type> Type *allot(cell size)
	{
		return (Type *)allot_object(Type::type_number,size);
	}

	inline void check_data_pointer(object *pointer)
	{
	#ifdef FACTOR_DEBUG
		if(!(current_gc && current_gc->op == collect_growing_heap_op))
		{
			assert((cell)pointer >= data->seg->start
				&& (cell)pointer < data->seg->end);
		}
	#endif
	}

	// generic arrays
	template<typename Array> Array *allot_uninitialized_array(cell capacity);
	template<typename Array> bool reallot_array_in_place_p(Array *array, cell capacity);
	template<typename Array> Array *reallot_array(Array *array_, cell capacity);

	// debug
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
	void print_callstack();
	void dump_cell(cell x);
	void dump_memory(cell from, cell to);
	template<typename Generation> void dump_generation(const char *name, Generation *gen);
	void dump_generations();
	void dump_objects(cell type);
	void find_data_references_step(cell *scan);
	void find_data_references(cell look_for_);
	void dump_code_heap();
	void factorbug();
	void primitive_die();

	// arrays
	inline void set_array_nth(array *array, cell slot, cell value);
	array *allot_array(cell capacity, cell fill_);
	void primitive_array();
	cell allot_array_1(cell obj_);
	cell allot_array_2(cell v1_, cell v2_);
	cell allot_array_4(cell v1_, cell v2_, cell v3_, cell v4_);
	void primitive_resize_array();
	cell std_vector_to_array(std::vector<cell> &elements);

	// strings
	cell string_nth(const string *str, cell index);
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

	// booleans
	cell tag_boolean(cell untagged)
	{
		return (untagged ? true_object : false_object);
	}

	// byte arrays
	byte_array *allot_byte_array(cell size);
	void primitive_byte_array();
	void primitive_uninitialized_byte_array();
	void primitive_resize_byte_array();

	template<typename Type> byte_array *byte_array_from_value(Type *value);

	// tuples
	void primitive_tuple();
	void primitive_tuple_boa();

	// words
	word *allot_word(cell name_, cell vocab_, cell hashcode_);
	void primitive_word();
	void primitive_word_code();
	void update_word_entry_point(word *w_);
	void primitive_optimized_p();
	void primitive_wrapper();
	void jit_compile_word(cell word_, cell def_, bool relocating);
	cell find_all_words();
	void compile_all_words();

	// math
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
	inline cell unbox_array_size();
	cell unbox_array_size_slow();
	void primitive_fixnum_to_float();
	void primitive_bignum_to_float();
	void primitive_format_float();
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
	cell from_signed_1(s8 n);
	cell from_unsigned_1(u8 n);
	cell from_signed_2(s16 n);
	cell from_unsigned_2(u16 n);
	cell from_signed_4(s32 n);
	cell from_unsigned_4(u32 n);
	cell from_signed_cell(fixnum integer);
	cell from_unsigned_cell(cell integer);
	cell from_signed_8(s64 n);
	s64 to_signed_8(cell obj);
	cell from_unsigned_8(u64 n);
	u64 to_unsigned_8(cell obj);
	float to_float(cell value);
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

	// tagged
	template<typename Type> Type *untag_check(cell value);

	// io
	void init_c_io();
	void io_error();
	FILE* safe_fopen(char *filename, char *mode);
	int safe_fgetc(FILE *stream);
	size_t safe_fread(void *ptr, size_t size, size_t nitems, FILE *stream);
	void safe_fputc(int c, FILE* stream);
	size_t safe_fwrite(void *ptr, size_t size, size_t nitems, FILE *stream);
	int safe_ftell(FILE *stream);
	void safe_fseek(FILE *stream, off_t offset, int whence);
	void safe_fflush(FILE *stream);
	void safe_fclose(FILE *stream);
	void primitive_fopen();
	FILE *pop_file_handle();
	void primitive_fgetc();
	void primitive_fread();
	void primitive_fputc();
	void primitive_fwrite();
	void primitive_ftell();
	void primitive_fseek();
	void primitive_fflush();
	void primitive_fclose();

	// code_block
	cell compute_entry_point_address(cell obj);
	cell compute_entry_point_pic_address(word *w, cell tagged_quot);
	cell compute_entry_point_pic_address(cell w_);
	cell compute_entry_point_pic_tail_address(cell w_);
	cell code_block_owner(code_block *compiled);
	void update_word_references(code_block *compiled, bool reset_inline_caches);
	void undefined_symbol();
	cell compute_dlsym_address(array *literals, cell index);
	cell compute_vm_address(cell arg);
	void store_external_address(instruction_operand op);
	cell compute_here_address(cell arg, cell offset, code_block *compiled);
	void initialize_code_block(code_block *compiled, cell literals);
	void initialize_code_block(code_block *compiled);
	void fixup_labels(array *labels, code_block *compiled);
	code_block *allot_code_block(cell size, code_block_type type);
	code_block *add_code_block(code_block_type type, cell code_, cell labels_, cell owner_, cell relocation_, cell parameters_, cell literals_);

	//code heap
	inline void check_code_pointer(cell ptr) { }

	template<typename Iterator> void each_code_block(Iterator &iter)
	{
		code->allocator->iterate(iter);
	}

	void init_code_heap(cell size);
	bool in_code_heap_p(cell ptr);
	void update_code_heap_words(bool reset_inline_caches);
	void initialize_code_blocks();
	void primitive_modify_code_heap();
	code_heap_room code_room();
	void primitive_code_room();
	void primitive_strip_stack_traces();
	cell code_blocks();
	void primitive_code_blocks();

	// callbacks
	void init_callbacks(cell size);
	void primitive_callback();

	// image
	void init_objects(image_header *h);
	void load_data_heap(FILE *file, image_header *h, vm_parameters *p);
	void load_code_heap(FILE *file, image_header *h, vm_parameters *p);
	bool save_image(const vm_char *saving_filename, const vm_char *filename);
	void primitive_save_image();
	void primitive_save_image_and_exit();
	void fixup_data(cell data_offset, cell code_offset);
	void fixup_code(cell data_offset, cell code_offset);
	void load_image(vm_parameters *p);

	// callstack
	template<typename Iterator> void iterate_callstack_object(callstack *stack_, Iterator &iterator);
	void check_frame(stack_frame *frame);
	callstack *allot_callstack(cell size);
	stack_frame *fix_callstack_top(stack_frame *top);
	stack_frame *second_from_top_stack_frame(context *ctx);
	cell capture_callstack(context *ctx);
	void primitive_callstack();
	void primitive_callstack_for();
	code_block *frame_code(stack_frame *frame);
	code_block_type frame_type(stack_frame *frame);
	cell frame_executing(stack_frame *frame);
	cell frame_executing_quot(stack_frame *frame);
	stack_frame *frame_successor(stack_frame *frame);
	cell frame_scan(stack_frame *frame);
	void primitive_callstack_to_array();
	stack_frame *innermost_stack_frame(callstack *stack);
	void primitive_innermost_stack_frame_executing();
	void primitive_innermost_stack_frame_scan();
	void primitive_set_innermost_stack_frame_quot();
	void primitive_callstack_bounds();
	template<typename Iterator> void iterate_callstack(context *ctx, Iterator &iterator);

	// alien
	char *pinned_alien_offset(cell obj);
	cell allot_alien(cell delegate_, cell displacement);
	cell allot_alien(void *address);
	void primitive_displaced_alien();
	void primitive_alien_address();
	void *alien_pointer();
	void primitive_dlopen();
	void primitive_dlsym();
	void primitive_dlclose();
	void primitive_dll_validp();
	char *alien_offset(cell obj);
	void to_value_struct(cell src, void *dest, cell size);
	cell from_value_struct(void *src, cell size);
	cell from_small_struct(cell x, cell y, cell size);
	cell from_medium_struct(cell x1, cell x2, cell x3, cell x4, cell size);

	// quotations
	void primitive_jit_compile();
	code_block *lazy_jit_compile_block();
	void primitive_array_to_quotation();
	void primitive_quotation_code();
	void set_quot_entry_point(quotation *quot, code_block *code);
	code_block *jit_compile_quot(cell owner_, cell quot_, bool relocating);
	void jit_compile_quot(cell quot_, bool relocating);
	fixnum quot_code_offset_to_scan(cell quot_, cell offset);
	cell lazy_jit_compile(cell quot);
	bool quot_compiled_p(quotation *quot);
	void primitive_quot_compiled_p();
	cell find_all_quotations();
	void initialize_all_quotations();

	// dispatch
	cell search_lookup_alist(cell table, cell klass);
	cell search_lookup_hash(cell table, cell klass, cell hashcode);
	cell nth_superclass(tuple_layout *layout, fixnum echelon);
	cell nth_hashcode(tuple_layout *layout, fixnum echelon);
	cell lookup_tuple_method(cell obj, cell methods);
	cell lookup_method(cell obj, cell methods);
	void primitive_lookup_method();
	cell object_class(cell obj);
	cell method_cache_hashcode(cell klass, array *array);
	void update_method_cache(cell cache, cell klass, cell method);
	void primitive_mega_cache_miss();
	void primitive_reset_dispatch_stats();
	void primitive_dispatch_stats();

	// inline cache
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

	// entry points
	void c_to_factor(cell quot);
	void unwind_native_frames(cell quot, stack_frame *to);

	// factor
	void default_parameters(vm_parameters *p);
	bool factor_arg(const vm_char *str, const vm_char *arg, cell *value);
	void init_parameters_from_args(vm_parameters *p, int argc, vm_char **argv);
	void prepare_boot_image();
	void init_factor(vm_parameters *p);
	void pass_args_to_factor(int argc, vm_char **argv);
	void start_factor(vm_parameters *p);
	void stop_factor();
	void start_embedded_factor(vm_parameters *p);
	void start_standalone_factor(int argc, vm_char **argv);
	char *factor_eval_string(char *string);
	void factor_eval_free(char *result);
	void factor_yield();
	void factor_sleep(long us);

	// os-*
	void primitive_existsp();
	void move_file(const vm_char *path1, const vm_char *path2);
	void init_ffi();
	void ffi_dlopen(dll *dll);
	void *ffi_dlsym(dll *dll, symbol_char *symbol);
	void ffi_dlclose(dll *dll);
	void c_to_factor_toplevel(cell quot);
	void init_signals();

	// os-windows
  #if defined(WINDOWS)
	const vm_char *vm_executable_path();
	const vm_char *default_image_path();
	void windows_image_path(vm_char *full_path, vm_char *temp_path, unsigned int length);
	BOOL windows_stat(vm_char *path);

  #if defined(WINNT)
	void open_console();
	LONG exception_handler(PEXCEPTION_RECORD e, void *frame, PCONTEXT c, void *dispatch);
  #endif

  #else  // UNIX
	void dispatch_signal(void *uap, void (handler)());
	void unix_init_signals();
  #endif

  #ifdef __APPLE__
	void call_fault_handler(exception_type_t exception, exception_data_type_t code, MACH_EXC_STATE_TYPE *exc_state, MACH_THREAD_STATE_TYPE *thread_state, MACH_FLOAT_STATE_TYPE *float_state);
  #endif

	factor_vm();
	~factor_vm();
};

}
