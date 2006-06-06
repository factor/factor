typedef struct {
	/* TAGGED header */
	CELL header;
	/* TAGGED hashcode */
	CELL hashcode;
	/* TAGGED word name */
	CELL name;
	/* TAGGED word vocabulary */
	CELL vocabulary;
	/* TAGGED on-disk primitive number */
	CELL primitive;
	/* TAGGED parameter to xt; used for colon definitions */
	CELL def;
	/* TAGGED property hash for library code */
	CELL props;
	/* UNTAGGED execution token: jump here to execute word */
	CELL xt;
} F_WORD;

typedef void (*XT)(F_WORD *word);

INLINE F_WORD *untag_word_fast(CELL tagged)
{
	return (F_WORD*)UNTAG(tagged);
}

INLINE F_WORD *untag_word(CELL tagged)
{
	type_check(WORD_TYPE,tagged);
	return untag_word_fast(tagged);
}

INLINE CELL tag_word(F_WORD *word)
{
	return RETAG(word,WORD_TYPE);
}

void update_xt(F_WORD* word);
void primitive_word(void);
void primitive_update_xt(void);
void primitive_word_compiledp(void);
void fixup_word(F_WORD* word);
void collect_word(F_WORD* word);
