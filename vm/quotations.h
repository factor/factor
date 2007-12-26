void set_quot_xt(F_QUOTATION *quot, F_COMPILED *code);
void jit_compile(CELL quot);
F_FASTCALL CELL primitive_jit_compile(CELL quot, F_STACK_FRAME *stack);
void uncurry(CELL obj);
DECLARE_PRIMITIVE(curry);
DECLARE_PRIMITIVE(array_to_quotation);
DECLARE_PRIMITIVE(quotation_xt);
DECLARE_PRIMITIVE(uncurry);
DECLARE_PRIMITIVE(strip_compiled_quotations);
