#define STACK_UNDERFLOW(stack,bot) ((stack) + CELLS < UNTAG(bot))
#define STACK_OVERFLOW(stack,bot) ((stack) + CELLS >= UNTAG(bot) + STACK_SIZE)

void reset_datastack(void);
void reset_callstack(void);
void fix_stacks(void);
void init_stacks(void);

void primitive_drop(void);
void primitive_dup(void);
void primitive_swap(void);
void primitive_over(void);
void primitive_pick(void);
void primitive_to_r(void);
void primitive_from_r(void);
VECTOR* stack_to_vector(CELL bottom, CELL top);
void primitive_datastack(void);
void primitive_callstack(void);
CELL vector_to_stack(VECTOR* vector, CELL bottom);
void primitive_set_datastack(void);
void primitive_set_callstack(void);
