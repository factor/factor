#include "factor.h"

/* When a word is executed we jump to the value of the xt field. However this
   value is an unportable function pointer, so in the image we store a primitive
   number that indexes a list of xts. */
void update_xt(F_WORD* word)
{
	word->xt = primitive_to_xt(word->primitive);
}

/* <word> ( primitive parameter plist -- word ) */
void primitive_word(void)
{
	F_WORD* word;

	maybe_garbage_collection();

	word = allot_object(WORD_TYPE,sizeof(F_WORD));
	word->hashcode = (CELL)word; /* initial address */
	word->xt = (CELL)undefined;
	word->primitive = 0;
	word->parameter = F;
	word->plist = F;
	word->call_count = 0;
	word->allot_count = 0;
	dpush(tag_word(word));
}

void primitive_update_xt(void)
{
	update_xt(untag_word(dpop()));
}

void primitive_word_compiledp(void)
{
	F_WORD* word = untag_word(dpop());
	box_boolean(word->xt != (CELL)docol && word->xt != (CELL)dosym);
}

void primitive_to_word(void)
{
	type_check(WORD_TYPE,dpeek());
}

void fixup_word(F_WORD* word)
{
	update_xt(word);
	fixup(&word->parameter);
	fixup(&word->plist);
}

void collect_word(F_WORD* word)
{
	copy_object(&word->parameter);
	copy_object(&word->plist);
}
