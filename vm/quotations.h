void jit_compile(F_QUOTATION *quot);
F_FASTCALL CELL primitive_jit_compile(CELL tagged, F_STACK_FRAME *stack);
XT quot_offset_to_pc(F_QUOTATION *quot, F_FIXNUM offset);
void uncurry(CELL obj);
DECLARE_PRIMITIVE(curry);
DECLARE_PRIMITIVE(array_to_quotation);
DECLARE_PRIMITIVE(quotation_xt);
DECLARE_PRIMITIVE(uncurry);
