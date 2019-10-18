CELL ds_size, cs_size;

#define STACK_UNDERFLOW(stack,bot) ((stack) + CELLS < UNTAG(bot))
#define STACK_OVERFLOW(stack,bot,top) ((stack) + CELLS >= UNTAG(bot) + top)

void reset_datastack(void);
void reset_callstack(void);
void fix_stacks(void);
void init_stacks(CELL ds_size, CELL cs_size);

void primitive_drop(void);
void primitive_2drop(void);
void primitive_3drop(void);
void primitive_dup(void);
void primitive_2dup(void);
void primitive_3dup(void);
void primitive_rot(void);
void primitive__rot(void);
void primitive_dupd(void);
void primitive_swapd(void);
void primitive_nip(void);
void primitive_2nip(void);
void primitive_tuck(void);
void primitive_over(void);
void primitive_pick(void);
void primitive_swap(void);
void primitive_to_r(void);
void primitive_from_r(void);
F_VECTOR* stack_to_vector(CELL bottom, CELL top);
void primitive_datastack(void);
void primitive_callstack(void);
CELL vector_to_stack(F_VECTOR* vector, CELL bottom);
void primitive_set_datastack(void);
void primitive_set_callstack(void);
