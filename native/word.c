#include "factor.h"

WORD* word(FIXNUM primitive, CELL parameter, CELL plist)
{
	WORD* word = (WORD*)allot_object(WORD_TYPE,sizeof(WORD));
	word->xt = primitive_to_xt(primitive);
	word->primitive = primitive;
	word->parameter = parameter;
	word->plist = plist;

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
	check_non_empty(env.dt);
	env.dt = tag_boolean(TAG(env.dt) == WORD_TYPE);
}

/* <word> ( primitive parameter plist -- word ) */
void primitive_word(void)
{
	CELL plist = env.dt;
	FIXNUM primitive;
	CELL parameter = dpop();
	check_non_empty(plist);
	check_non_empty(parameter);
	primitive = untag_fixnum(dpop());
	env.dt = tag_word(word(primitive,parameter,plist));
}

void primitive_word_primitive(void)
{
	env.dt = tag_fixnum(untag_word(env.dt)->primitive);
}

void primitive_set_word_primitive(void)
{
	WORD* word = untag_word(env.dt);
	word->primitive = untag_fixnum(dpop());
	update_xt(word);
	env.dt = dpop();
}

void primitive_word_parameter(void)
{
	env.dt = untag_word(env.dt)->parameter;
}

void primitive_set_word_parameter(void)
{
	check_non_empty(dpeek());
	untag_word(env.dt)->parameter = dpop();
	env.dt = dpop();
}

void primitive_word_plist(void)
{
	env.dt = untag_word(env.dt)->plist;
}

void primitive_set_word_plist(void)
{
	check_non_empty(dpeek());
	untag_word(env.dt)->plist = dpop();
	env.dt = dpop();
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
