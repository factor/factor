#define STACK_UNDERFLOW_CHECKING

#define STACK_UNDERFLOW(stack,bot) ((stack) < UNTAG(bot) + sizeof(ARRAY))
#define STACK_OVERFLOW(stack,bot) ((stack) >= UNTAG(bot) + object_size(bot))

INLINE void check_stacks(void)
{

#ifdef STACK_UNDERFLOW_CHECKING
	if(STACK_OVERFLOW(env.ds,env.ds_bot))
		general_error(ERROR_OVERFLOW,F);
	if(STACK_OVERFLOW(env.cs,env.cs_bot))
		general_error(ERROR_OVERFLOW,F);
#endif

}

void reset_datastack(void);
void reset_callstack(void);

void primitive_drop(void);
void primitive_dup(void);
void primitive_swap(void);
void primitive_over(void);
void primitive_pick(void);
void primitive_nip(void);
void primitive_tuck(void);
void primitive_rot(void);
void primitive_to_r(void);
void primitive_from_r(void);
VECTOR* stack_to_vector(CELL top, CELL bottom);
void primitive_datastack(void);
void primitive_callstack(void);
CELL vector_to_stack(VECTOR* vector, CELL bottom);
void primitive_set_datastack(void);
void primitive_set_callstack(void);
