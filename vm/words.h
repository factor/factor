DEFINE_UNTAG(F_WORD,WORD_TYPE,word)

F_WORD *allot_word(CELL vocab, CELL name);

void primitive_word(void);
void primitive_word_xt(void);
void update_word_xt(F_WORD *word);

INLINE bool word_optimized_p(F_WORD *word)
{
	return word->code->block.type == WORD_TYPE;
}

void primitive_optimized_p(void);

void primitive_wrapper(void);
