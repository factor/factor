F_WORD *allot_word(CELL vocab, CELL name);

PRIMITIVE(word);
PRIMITIVE(word_xt);
void update_word_xt(CELL word);

inline bool word_optimized_p(F_WORD *word)
{
	return word->code->block.type == WORD_TYPE;
}

PRIMITIVE(optimized_p);

PRIMITIVE(wrapper);
