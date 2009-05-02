DEFINE_UNTAG(F_QUOTATION,QUOTATION_TYPE,quotation)

INLINE CELL tag_quotation(F_QUOTATION *quotation)
{
	return RETAG(quotation,QUOTATION_TYPE);
}

struct quotation_jit : public jit {
	gc_root<F_ARRAY> array;
	bool compiling, relocate;

	quotation_jit(CELL quot, bool compiling_, bool relocate_)
		: jit(QUOTATION_TYPE,quot),
		  array(owner.as<F_QUOTATION>().untagged()->array),
		  compiling(compiling_),
		  relocate(relocate_) {};

	void emit_mega_cache_lookup(CELL methods, F_FIXNUM index, CELL cache);
	bool primitive_call_p(CELL i);
	bool fast_if_p(CELL i);
	bool fast_dip_p(CELL i);
	bool fast_2dip_p(CELL i);
	bool fast_3dip_p(CELL i);
	bool mega_lookup_p(CELL i);
	bool stack_frame_p();
	void iterate_quotation();
};

void set_quot_xt(F_QUOTATION *quot, F_CODE_BLOCK *code);
void jit_compile(CELL quot, bool relocate);
F_FIXNUM quot_code_offset_to_scan(CELL quot, CELL offset);

void primitive_jit_compile(void);

F_FASTCALL CELL lazy_jit_compile_impl(CELL quot, F_STACK_FRAME *stack);

void compile_all_words(void);

void primitive_array_to_quotation(void);
void primitive_quotation_xt(void);

