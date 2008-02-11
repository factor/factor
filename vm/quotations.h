void set_quot_xt(F_QUOTATION *quot, F_COMPILED *code);
void jit_compile(CELL quot, bool relocate);
F_FASTCALL CELL primitive_jit_compile(CELL quot, F_STACK_FRAME *stack);
F_FIXNUM quot_code_offset_to_scan(CELL quot, F_FIXNUM offset);
DECLARE_PRIMITIVE(array_to_quotation);
DECLARE_PRIMITIVE(quotation_xt);
