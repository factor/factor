DLLEXPORT F_FASTCALL CELL jit_compile(CELL tagged, F_STACK_FRAME *stack);
XT quot_offset_to_pc(F_QUOTATION *quot, F_FIXNUM offset);

DECLARE_PRIMITIVE(curry);
DECLARE_PRIMITIVE(array_to_quotation);
DECLARE_PRIMITIVE(quotation_xt);
DECLARE_PRIMITIVE(uncurry);
