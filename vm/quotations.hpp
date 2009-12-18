namespace factor
{

struct quotation_jit : public jit {
	data_root<array> elements;
	bool compiling, relocate;

	explicit quotation_jit(cell owner, bool compiling_, bool relocate_, factor_vm *vm)
		: jit(code_block_unoptimized,owner,vm),
		  elements(false_object,vm),
		  compiling(compiling_),
		  relocate(relocate_){};

	void init_quotation(cell quot);
	void emit_mega_cache_lookup(cell methods, fixnum index, cell cache);
	bool primitive_call_p(cell i, cell length);
	bool trivial_quotation_p(array *elements);
	void emit_quot(cell quot);
	bool fast_if_p(cell i, cell length);
	bool fast_dip_p(cell i, cell length);
	bool fast_2dip_p(cell i, cell length);
	bool fast_3dip_p(cell i, cell length);
	bool mega_lookup_p(cell i, cell length);
	bool declare_p(cell i, cell length);
	bool word_stack_frame_p(cell obj);
	bool stack_frame_p();
	void iterate_quotation();
};

VM_C_API cell lazy_jit_compile_impl(cell quot, factor_vm *parent);

}
