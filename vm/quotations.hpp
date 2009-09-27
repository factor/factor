namespace factor
{

struct quotation_jit : public jit {
	gc_root<array> elements;
	bool compiling, relocate;

	quotation_jit(cell quot, bool compiling_, bool relocate_, factor_vm *vm)
		: jit(QUOTATION_TYPE,quot,vm),
		  elements(owner.as<quotation>().untagged()->array,vm),
		  compiling(compiling_),
		  relocate(relocate_){};

	void emit_mega_cache_lookup(cell methods, fixnum index, cell cache);
	bool primitive_call_p(cell i, cell length);
	bool fast_if_p(cell i, cell length);
	bool fast_dip_p(cell i, cell length);
	bool fast_2dip_p(cell i, cell length);
	bool fast_3dip_p(cell i, cell length);
	bool mega_lookup_p(cell i, cell length);
	bool declare_p(cell i, cell length);
	bool stack_frame_p();
	void iterate_quotation();
};


VM_ASM_API cell lazy_jit_compile_impl(cell quot, stack_frame *stack, factor_vm *myvm);

}
