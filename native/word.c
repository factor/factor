#include "factor.h"

WORD* word(CELL primitive, CELL parameter, CELL plist)
{
	WORD* word = allot_object(WORD_TYPE,sizeof(WORD));
	word->xt = primitive_to_xt(primitive);
	word->primitive = primitive;
	word->parameter = parameter;
	word->plist = plist;
	word->call_count = 0;

	return word;
}

/* When a word is executed we jump to the value of the xt field. However this
   value is an unportable function pointer, so in the image we store a primitive
   number that indexes a list of xts. */
void update_xt(WORD* word)
{
	word->xt = primitive_to_xt(word->primitive);
}

void primitive_wordp(void)
{
	drepl(tag_boolean(typep(WORD_TYPE,dpeek())));
}

/* <word> ( primitive parameter plist -- word ) */
void primitive_word(void)
{
	CELL plist = dpop();
	FIXNUM primitive;
	CELL parameter = dpop();
	primitive = to_fixnum(dpop());
	dpush(tag_word(word(primitive,parameter,plist)));
}

void primitive_word_primitive(void)
{
	drepl(tag_fixnum(untag_word(dpeek())->primitive));
}

void primitive_set_word_primitive(void)
{
	WORD* word = untag_word(dpop());
	word->primitive = to_fixnum(dpop());
	update_xt(word);
}

void primitive_word_parameter(void)
{
	drepl(untag_word(dpeek())->parameter);
}

void primitive_set_word_parameter(void)
{
	WORD* word = untag_word(dpop());
	word->parameter = dpop();
}

void primitive_word_plist(void)
{
	drepl(untag_word(dpeek())->plist);
}

void primitive_set_word_plist(void)
{
	WORD* word = untag_word(dpop());
	word->plist = dpop();
}

void primitive_word_call_count(void)
{
	drepl(tag_fixnum(untag_word(dpeek())->call_count));
}

void primitive_set_word_call_count(void)
{
	WORD* word = untag_word(dpop());
	word->call_count = to_fixnum(dpop());
}

void primitive_word_allot_count(void)
{
	drepl(tag_fixnum(untag_word(dpeek())->allot_count));
}

void primitive_set_word_allot_count(void)
{
	WORD* word = untag_word(dpop());
	word->allot_count = to_fixnum(dpop());
}

void fixup_word(WORD* word)
{
	word->xt = primitive_to_xt(word->primitive);
	fixup(&word->parameter);
	fixup(&word->plist);
}

void collect_word(WORD* word)
{
	copy_object(&word->parameter);
	copy_object(&word->plist);
}
