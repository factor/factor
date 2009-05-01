#include "master.h"

void init_inline_caching(int max_size)
{
	max_pic_size = max_size;
}

void deallocate_inline_cache(CELL return_address)
{
	/* Find the call target. */
	XT old_xt = (XT)get_call_target(return_address);
	F_CODE_BLOCK *old_block = (F_CODE_BLOCK *)old_xt - 1;
	CELL old_type = old_block->block.type;

#ifdef FACTOR_DEBUG
	/* The call target was either another PIC,
	   or a compiled quotation (megamorphic stub) */
	assert(old_type == PIC_TYPE || old_type == QUOTATION_TYPE);
#endif

	if(old_type == PIC_TYPE)
		heap_free(&code_heap,&old_block->block);
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

static void jit_emit_check(F_JIT *jit, CELL class)
{
	CELL template;
	if(TAG(class) == FIXNUM_TYPE && untag_fixnum_fast(class) < HEADER_TYPE)
		template = userenv[PIC_CHECK_TAG];
	else
		template = userenv[PIC_CHECK];

	jit_emit_with(jit,template,class);
}

/* index: 0 = top of stack, 1 = item underneath, etc
   cache_entries: array of class/method pairs */
static F_CODE_BLOCK *compile_inline_cache(F_FIXNUM index, CELL generic_word, CELL methods, CELL cache_entries)
{
#ifdef FACTOR_DEBUG
	type_check(WORD_TYPE,generic_word);
	type_check(ARRAY_TYPE,cache_entries);
#endif

	REGISTER_ROOT(generic_word);
	REGISTER_ROOT(methods);
	REGISTER_ROOT(cache_entries);

	CELL inline_cache_type = determine_inline_cache_type(cache_entries);

	update_pic_count(inline_cache_type);

	F_JIT jit;
	jit_init(&jit,PIC_TYPE,generic_word);

	/* Generate machine code to determine the object's class. */
	jit_emit_class_lookup(&jit,index,inline_cache_type);

	/* Generate machine code to check, in turn, if the class is one of the cached entries. */
	CELL i;
	for(i = 0; i < array_capacity(untag_object(cache_entries)); i += 2)
	{
		/* Class equal? */
		CELL class = array_nth(untag_object(cache_entries),i);
		jit_emit_check(&jit,class);

		/* Yes? Jump to method */
		CELL method = array_nth(untag_object(cache_entries),i + 1);
		jit_emit_with(&jit,userenv[PIC_HIT],method);
	}

	/* Generate machine code to handle a cache miss, which ultimately results in
	   this function being called again.

	   The inline-cache-miss primitive call receives enough information to
	   reconstruct the PIC. */
	jit_push(&jit,generic_word);
	jit_push(&jit,methods);
	jit_push(&jit,tag_fixnum(index));
	jit_push(&jit,cache_entries);
	jit_word_jump(&jit,userenv[PIC_MISS_WORD]);

	F_CODE_BLOCK *code = jit_make_code_block(&jit);
	relocate_code_block(code);

	jit_dispose(&jit);

	UNREGISTER_ROOT(cache_entries);
	UNREGISTER_ROOT(methods);
	UNREGISTER_ROOT(generic_word);

	return code;
}

/* A generic word's definition performs general method lookup. Allocates memory */
static XT megamorphic_call_stub(CELL generic_word)
{
	return untag_word(generic_word)->xt;
}

static CELL inline_cache_size(CELL cache_entries)
{
	return (cache_entries == F ? 0 : array_capacity(untag_array(cache_entries)) / 2);
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
		return tag_array(cache_entries_array);
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
	check_code_pointer(return_address);

	/* Since each PIC is only referenced from a single call site,
	   if the old call target was a PIC, we can deallocate it immediately,
	   instead of leaving dead PICs around until the next GC. */
	deallocate_inline_cache(return_address);

	CELL cache_entries = dpop();
	F_FIXNUM index = untag_fixnum_fast(dpop());
	CELL methods = dpop();
	CELL generic_word = dpop();
	CELL object = get(ds - index * CELLS);

	XT xt;

	CELL pic_size = inline_cache_size(cache_entries);

	update_pic_transitions(pic_size);

	if(pic_size >= max_pic_size)
		xt = megamorphic_call_stub(generic_word);
	else
	{
		REGISTER_ROOT(generic_word);
		REGISTER_ROOT(cache_entries);
		REGISTER_ROOT(methods);

		CELL class = object_class(object);
		CELL method = lookup_method(object,methods);

		cache_entries = add_inline_cache_entry(cache_entries,class,method);
		xt = compile_inline_cache(index,generic_word,methods,cache_entries) + 1;

		UNREGISTER_ROOT(methods);
		UNREGISTER_ROOT(cache_entries);
		UNREGISTER_ROOT(generic_word);
	}

	/* Install the new stub. */
	set_call_target(return_address,(CELL)xt);

#ifdef PIC_DEBUG
	printf("Updated call site 0x%lx with 0x%lx\n",return_address,(CELL)xt);
#endif

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
