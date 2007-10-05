#define FRAME_RETURN_ADDRESS(frame) *(XT *)(frame_successor(frame) + 1)

INLINE void flush_icache(CELL start, CELL len) {}

F_FASTCALL void c_to_factor(CELL quot);
F_FASTCALL void throw_impl(CELL quot, F_STACK_FRAME *rewind_to);
F_FASTCALL void undefined(CELL word);
F_FASTCALL void dosym(CELL word);
F_FASTCALL void docol_profiling(CELL word);
F_FASTCALL void docol(CELL word);
F_FASTCALL void lazy_jit_compile(CELL quot);

void set_callstack(F_STACK_FRAME *to, F_STACK_FRAME *from, CELL length, void *memcpy);
