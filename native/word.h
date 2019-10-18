typedef struct {
	/* TAGGED header */
	CELL header;
	/* TAGGED hashcode */
	CELL hashcode;
	/* untagged execution token: jump here to execute word */
	CELL xt;
	/* untagged on-disk primitive number */
	CELL primitive;
	/* TAGGED parameter to xt; used for colon definitions */
	CELL parameter;
	/* TAGGED property list for library code */
	CELL plist;
	/* UNTAGGED call count incremented by profiler */
	CELL call_count;
	/* UNTAGGED amount of memory allocated in word */
	CELL allot_count;
} F_WORD;

typedef void (*XT)(F_WORD* word);

INLINE F_WORD* untag_word_fast(CELL tagged)
{
	return (F_WORD*)UNTAG(tagged);
}

INLINE F_WORD* untag_word(CELL tagged)
{
	type_check(WORD_TYPE,tagged);
	return untag_word_fast(tagged);
}

void update_xt(F_WORD* word);
void primitive_word(void);
void primitive_update_xt(void);
void primitive_word_compiledp(void);
void primitive_to_word(void);
void fixup_word(F_WORD* word);
void collect_word(F_WORD* word);
