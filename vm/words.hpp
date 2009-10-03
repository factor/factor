namespace factor
{

inline bool word_optimized_p(word *word)
{
	return word->code->type == WORD_TYPE;
}

}
