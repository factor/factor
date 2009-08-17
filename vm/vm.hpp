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
	// next method here:

};

extern factorvm *vm;

}
