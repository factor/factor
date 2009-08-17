namespace factor
{

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
	void bignum_divide_unsigned_large_denominator(bignum * numerator, bignum * denominator, bignum * * quotient, bignum * * remainder, int q_negative_p, int r_negative_p);
	// next method here:

};

extern factorvm *vm;

}
