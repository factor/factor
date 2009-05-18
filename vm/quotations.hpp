namespace factor
{

struct quotation_jit : public jit {
	gc_root<array> elements;
	bool compiling, relocate;

	quotation_jit(cell quot, bool compiling_, bool relocate_)
		: jit(QUOTATION_TYPE,quot),
		  elements(owner.as<quotation>().untagged()->array),
		  compiling(compiling_),
		  relocate(relocate_) {};

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

void set_quot_xt(quotation *quot, code_block *code);
void jit_compile(cell quot, bool relocate);
fixnum quot_code_offset_to_scan(cell quot, cell offset);

PRIMITIVE(jit_compile);

void compile_all_words();

PRIMITIVE(array_to_quotation);
PRIMITIVE(quotation_xt);

VM_ASM_API cell lazy_jit_compile_impl(cell quot, stack_frame *stack);

PRIMITIVE(quot_compiled_p);

}
