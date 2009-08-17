namespace factor
{

PRIMITIVE(word);
PRIMITIVE(word_xt);

inline bool word_optimized_p(word *word)
{
	return word->code->type == WORD_TYPE;
}

PRIMITIVE(optimized_p);
PRIMITIVE(wrapper);

}
