namespace factor
{

word *allot_word(cell vocab, cell name);

PRIMITIVE(word);
PRIMITIVE(word_xt);
void update_word_xt(cell word);

inline bool word_optimized_p(word *word)
{
	return word->code->type == WORD_TYPE;
}

PRIMITIVE(optimized_p);

PRIMITIVE(wrapper);

}
