DEFINE_UNTAG(F_QUOTATION,QUOTATION_TYPE,quotation)

INLINE CELL tag_quotation(F_QUOTATION *quotation)
{
	return RETAG(quotation,QUOTATION_TYPE);
}

void set_quot_xt(F_QUOTATION *quot, F_CODE_BLOCK *code);
void jit_compile(CELL quot, bool relocate);
F_FASTCALL CELL lazy_jit_compile_impl(CELL quot, F_STACK_FRAME *stack);
F_FIXNUM quot_code_offset_to_scan(CELL quot, CELL offset);
void primitive_array_to_quotation(void);
void primitive_quotation_xt(void);
void primitive_jit_compile(void);
void compile_all_words(void);
