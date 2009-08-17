namespace factor
{

struct quotation_jit : public jit {
	gc_root<array> elements;
	bool compiling, relocate;

	quotation_jit(cell quot, bool compiling_, bool relocate_, factorvm *vm)
		: jit(QUOTATION_TYPE,quot,vm),
		  elements(owner.as<quotation>().untagged()->array,vm),
		  compiling(compiling_),
		  relocate(relocate_){};

	void emit_mega_cache_lookup(cell methods, fixnum index, cell cache);
	bool primitive_call_p(cell i);
	bool fast_if_p(cell i);
	bool fast_dip_p(cell i);
	bool fast_2dip_p(cell i);
	bool fast_3dip_p(cell i);
	bool mega_lookup_p(cell i);
	bool stack_frame_p();
	void iterate_quotation();
};

PRIMITIVE(jit_compile);

PRIMITIVE(array_to_quotation);
PRIMITIVE(quotation_xt);

VM_ASM_API cell lazy_jit_compile_impl(cell quot, stack_frame *stack);

PRIMITIVE(quot_compiled_p);

}
