typedef struct {
	CELL type;
	CELL owner;
	F_GROWABLE_BYTE_ARRAY code;
	F_GROWABLE_BYTE_ARRAY relocation;
	F_GROWABLE_ARRAY literals;
} F_JIT;

void jit_init(F_JIT *jit, CELL jit_type, CELL owner);
F_CODE_BLOCK *jit_make_code_block(F_JIT *jit);
void jit_dispose(F_JIT *jit);

INLINE F_BYTE_ARRAY *code_to_emit(CELL template)
{
	return untag_object(array_nth(untag_object(template),0));
}

void jit_emit(F_JIT *jit, CELL template);

/* Allocates memory */
INLINE void jit_add_literal(F_JIT *jit, CELL literal)
{
	growable_array_add(&jit->literals,literal);
}

/* Allocates memory */
INLINE void jit_emit_with(F_JIT *jit, CELL template, CELL argument)
{
	REGISTER_ROOT(template);
	jit_add_literal(jit,argument);
	UNREGISTER_ROOT(template);
	jit_emit(jit,template);
}

/* Allocates memory */
INLINE void jit_push(F_JIT *jit, CELL literal)
{
	jit_emit_with(jit,userenv[JIT_PUSH_IMMEDIATE],literal);
}

/* Allocates memory */
INLINE void jit_word_jump(F_JIT *jit, CELL word)
{
	jit_emit_with(jit,userenv[JIT_WORD_JUMP],word);
}

/* Allocates memory */
INLINE void jit_word_call(F_JIT *jit, CELL word)
{
	jit_emit_with(jit,userenv[JIT_WORD_CALL],word);
}

/* Allocates memory */
INLINE void jit_emit_subprimitive(F_JIT *jit, F_WORD *word)
{
	REGISTER_UNTAGGED(word);
	if(array_nth(untag_object(word->subprimitive),1) != F)
		jit_add_literal(jit,T);
	UNREGISTER_UNTAGGED(word);

	jit_emit(jit,word->subprimitive);
}
