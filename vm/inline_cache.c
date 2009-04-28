#include "master.h"

void init_inline_caching(int max_size)
{
	max_pic_size = max_size;
}

/* Figure out what kind of type check the PIC needs based on the methods
it contains */
static CELL determine_inline_cache_type(CELL cache_entries)
{
	F_ARRAY *array = untag_object(cache_entries);

	bool  seen_hi_tag = false, seen_tuple = false;

	CELL i;
	for(i = 0; i < array_capacity(array); i += 2)
	{
		CELL class = array_nth(array,i);
		F_FIXNUM type;

		/* Is it a tuple layout? */
		switch(type_of(class))
		{
		case FIXNUM_TYPE:
			type = untag_fixnum_fast(class);
			if(type >= HEADER_TYPE)
				seen_hi_tag = true;
			break;
		case ARRAY_TYPE:
			seen_tuple = true;
			break;
		default:
			critical_error("Expected a fixnum or array",class);
			break;
		}
	}

	if(seen_hi_tag && seen_tuple) return PIC_HI_TAG_TUPLE;
	if(seen_hi_tag && !seen_tuple) return PIC_HI_TAG;
	if(!seen_hi_tag && seen_tuple) return PIC_TUPLE;
	if(!seen_hi_tag && !seen_tuple) return PIC_TAG;

	critical_error("Oops",0);
	return -1;
}

static void update_pic_count(CELL type)
{
	pic_counts[type - PIC_TAG]++;
}

/* picker: one of dup, over, pick
   cache_entries: array of class/method pairs */
static F_CODE_BLOCK *compile_inline_cache(CELL picker, CELL generic_word, CELL cache_entries)
{
	REGISTER_ROOT(picker);
	REGISTER_ROOT(generic_word);
	REGISTER_ROOT(cache_entries);

	CELL inline_cache_type = determine_inline_cache_type(cache_entries);

	update_pic_count(inline_cache_type);

	F_JIT jit;
	jit_init(&jit,WORD_TYPE,generic_word);

	/* Generate machine code to determine the object's class. */
	jit_emit_subprimitive(&jit,untag_object(picker));
	jit_emit(&jit,userenv[inline_cache_type]);

	/* Generate machine code to check, in turn, if the class is one of the cached entries. */
	CELL i;
	for(i = 0; i < array_capacity(untag_object(cache_entries)); i += 2)
	{
		/* Class equal? */
		CELL class = array_nth(untag_object(cache_entries),i);
		jit_emit_with(&jit,userenv[PIC_CHECK],class);

		/* Yes? Jump to method */
		CELL method = array_nth(untag_object(cache_entries),i + 1);
		jit_emit_with(&jit,userenv[PIC_HIT],method);
	}

	/* Generate machine code to handle a cache miss, which ultimately results in
	   this function being called again.

	   The inline-cache-miss primitive call receives enough information to
	   reconstruct the PIC. We also execute the picker again, so that the
	   object being dispatched on can be popped from the top of the stack. */
	jit_emit_subprimitive(&jit,untag_object(picker));
	jit_push(&jit,generic_word);
	jit_push(&jit,cache_entries);
	jit_word_jump(&jit,userenv[PIC_MISS_WORD]);

	F_CODE_BLOCK *code = jit_make_code_block(&jit);
	jit_dispose(&jit);

	UNREGISTER_ROOT(cache_entries);
	UNREGISTER_ROOT(generic_word);
	UNREGISTER_ROOT(picker);

	return code;
}

/* A generic word's definition performs general method lookup. Allocates memory */
static F_CODE_BLOCK *megamorphic_call_stub(CELL generic_word)
{
	F_WORD *word = untag_word(generic_word);
	REGISTER_UNTAGGED(word);
	jit_compile(word->def,true);
	UNREGISTER_UNTAGGED(word);
	return untag_quotation(word->def)->code;
}

/* Assumes that generic word definitions look like:
   [ <picker> <methods> <cache> lookup-method (execute) ]
*/
static void examine_generic_word(CELL generic_word, CELL *picker, CELL *all_methods)
{
	CELL def = untag_word(generic_word)->def;
	F_QUOTATION *quot = untag_quotation(def);
	F_ARRAY *array = untag_object(quot->array);

#ifdef FACTOR_DEBUG
	assert(array_capacity(array) == 5);
	type_check(WORD_TYPE,array_nth(array,0));
	type_check(ARRAY_TYPE,array_nth(array,1));
	type_check(ARRAY_TYPE,array_nth(array,2));
	type_check(WORD_TYPE,array_nth(array,3));
	type_check(WORD_TYPE,array_nth(array,4));
#endif

	*picker = array_nth(array,0);
	*all_methods = array_nth(array,1);
}

static CELL inline_cache_size(CELL cache_entries)
{
	return (cache_entries == F ? 0 : array_capacity(untag_array(cache_entries)));
}

/* Allocates memory */
static CELL add_inline_cache_entry(CELL cache_entries, CELL class, CELL method)
{
	if(cache_entries == F)
		return allot_array_2(class,method);
	else
	{
		F_ARRAY *cache_entries_array = untag_object(cache_entries);
		CELL pic_size = array_capacity(cache_entries_array);
		cache_entries_array = reallot_array(cache_entries_array,pic_size + 2);
		set_array_nth(cache_entries_array,pic_size,class);
		set_array_nth(cache_entries_array,pic_size + 1,method);
		return tag_object(cache_entries_array);
	}
}

static void update_pic_transitions(CELL pic_size)
{
	if(pic_size == max_pic_size)
		pic_to_mega_transitions++;
	else if(pic_size == 0)
		cold_call_to_ic_transitions++;
	else if(pic_size == 1)
		ic_to_pic_transitions++;
}

/* The cache_entries parameter is either f (on cold call site) or an array (on cache miss).
Called from assembly with the actual return address */
XT inline_cache_miss(CELL return_address)
{
	CELL cache_entries = dpop();
	CELL generic_word = dpop();
	CELL object = dpop();

	F_CODE_BLOCK *block;

	CELL pic_size = inline_cache_size(cache_entries);

	update_pic_transitions(pic_size);

	if(pic_size >= max_pic_size)
		block = megamorphic_call_stub(generic_word);
	else
	{
		CELL picker, all_methods;
		examine_generic_word(generic_word,&picker,&all_methods);

		REGISTER_ROOT(generic_word);
		REGISTER_ROOT(cache_entries);
		REGISTER_ROOT(picker);
		REGISTER_ROOT(all_methods);

		CELL class = object_class(object);
		CELL method = lookup_method(object,all_methods);

		cache_entries = add_inline_cache_entry(cache_entries,class,method);		
		block = compile_inline_cache(picker,generic_word,cache_entries);

		UNREGISTER_ROOT(all_methods);
		UNREGISTER_ROOT(picker);
		UNREGISTER_ROOT(cache_entries);
		UNREGISTER_ROOT(generic_word);
	}

	/* Install the new stub. */
	XT xt = (block + 1);
	set_call_site(return_address,(CELL)xt);

	return xt;
}

void primitive_reset_inline_cache_stats(void)
{
	cold_call_to_ic_transitions = ic_to_pic_transitions = pic_to_mega_transitions = 0;
	CELL i;
	for(i = 0; i < 4; i++) pic_counts[i] = 0;
}

void primitive_inline_cache_stats(void)
{
	GROWABLE_ARRAY(stats);
	GROWABLE_ARRAY_ADD(stats,allot_cell(cold_call_to_ic_transitions));
	GROWABLE_ARRAY_ADD(stats,allot_cell(ic_to_pic_transitions));
	GROWABLE_ARRAY_ADD(stats,allot_cell(pic_to_mega_transitions));
	CELL i;
	for(i = 0; i < 4; i++)
		GROWABLE_ARRAY_ADD(stats,allot_cell(pic_counts[i]));
	GROWABLE_ARRAY_TRIM(stats);
	GROWABLE_ARRAY_DONE(stats);
	dpush(stats);
}
