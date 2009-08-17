#include "master.hpp"

namespace factor
{


void factorvm::init_profiler()
{
	profiling_p = false;
}


/* Allocates memory */
code_block *factorvm::compile_profiling_stub(cell word_)
{
	gc_root<word> word(word_,this);

	jit jit(WORD_TYPE,word.value(),this);
	jit.emit_with(userenv[JIT_PROFILING],word.value());

	return jit.to_code_block();
}


/* Allocates memory */
void factorvm::set_profiling(bool profiling)
{
	if(profiling == profiling_p)
		return;

	profiling_p = profiling;

	/* Push everything to tenured space so that we can heap scan
	and allocate profiling blocks if necessary */
	gc();

	gc_root<array> words(find_all_words(),this);

	cell i;
	cell length = array_capacity(words.untagged());
	for(i = 0; i < length; i++)
	{
		tagged<word> word(array_nth(words.untagged(),i));
		if(profiling)
			word->counter = tag_fixnum(0);
		update_word_xt(word.value());
	}

	/* Update XTs in code heap */
	iterate_code_heap(factor::relocate_code_block);
}


inline void factorvm::vmprim_profiling()
{
	set_profiling(to_boolean(dpop()));
}

PRIMITIVE(profiling)
{
	PRIMITIVE_GETVM()->vmprim_profiling();
}

}
