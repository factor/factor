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

	maybe_gc(sizeof(F_WORD));

	word = allot_object(WORD_TYPE,sizeof(F_WORD));
	word->hashcode = tag_fixnum((CELL)word); /* initial address */
	word->xt = (CELL)undefined;
	word->primitive = 0;
	word->def = F;
	word->props = F;
	dpush(tag_object(word));
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

void fixup_word(F_WORD* word)
{
	/* If this is a compiled word, relocate the code pointer. Otherwise,
	reset it based on the primitive number of the word. */
	if(word->xt >= code_relocation_base
		&& word->xt < code_relocation_base
		- compiling.base + compiling.limit)
		code_fixup(&word->xt);
	else
		update_xt(word);

	data_fixup(&word->def);
	data_fixup(&word->props);
}

void collect_word(F_WORD* word)
{
	copy_handle(&word->def);
	copy_handle(&word->props);
}
