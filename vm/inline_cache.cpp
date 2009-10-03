#include "master.hpp"

namespace factor
{

void factor_vm::init_inline_caching(int max_size)
{
	max_pic_size = max_size;
}

void factor_vm::deallocate_inline_cache(cell return_address)
{
	/* Find the call target. */
	void *old_xt = get_call_target(return_address);
	check_code_pointer((cell)old_xt);

	code_block *old_block = (code_block *)old_xt - 1;
	cell old_type = old_block->type;

#ifdef FACTOR_DEBUG
	/* The call target was either another PIC,
	   or a compiled quotation (megamorphic stub) */
	assert(old_type == PIC_TYPE || old_type == QUOTATION_TYPE);
#endif

	if(old_type == PIC_TYPE)
		code->heap_free(old_block);
}

/* Figure out what kind of type check the PIC needs based on the methods
it contains */
cell factor_vm::determine_inline_cache_type(array *cache_entries)
{
	bool seen_hi_tag = false, seen_tuple = false;

	cell i;
	for(i = 0; i < array_capacity(cache_entries); i += 2)
	{
		cell klass = array_nth(cache_entries,i);

		/* Is it a tuple layout? */
		switch(TAG(klass))
		{
		case FIXNUM_TYPE:
			{
				fixnum type = untag_fixnum(klass);
				if(type >= HEADER_TYPE)
					seen_hi_tag = true;
			}
			break;
		case ARRAY_TYPE:
			seen_tuple = true;
			break;
		default:
			critical_error("Expected a fixnum or array",klass);
			break;
		}
	}

	if(seen_hi_tag && seen_tuple) return PIC_HI_TAG_TUPLE;
	if(seen_hi_tag && !seen_tuple) return PIC_HI_TAG;
	if(!seen_hi_tag && seen_tuple) return PIC_TUPLE;
	if(!seen_hi_tag && !seen_tuple) return PIC_TAG;

	critical_error("Oops",0);
	return 0;
}

void factor_vm::update_pic_count(cell type)
{
	pic_counts[type - PIC_TAG]++;
}

struct inline_cache_jit : public jit {
	fixnum index;

	explicit inline_cache_jit(cell generic_word_,factor_vm *vm) : jit(PIC_TYPE,generic_word_,vm) {};

	void emit_check(cell klass);
	void compile_inline_cache(fixnum index,
				  cell generic_word_,
				  cell methods_,
				  cell cache_entries_,
				  bool tail_call_p);
};

void inline_cache_jit::emit_check(cell klass)
{
	cell code_template;
	if(TAG(klass) == FIXNUM_TYPE && untag_fixnum(klass) < HEADER_TYPE)
		code_template = parent_vm->userenv[PIC_CHECK_TAG];
	else
		code_template = parent_vm->userenv[PIC_CHECK];

	emit_with(code_template,klass);
}

/* index: 0 = top of stack, 1 = item underneath, etc
   cache_entries: array of class/method pairs */
void inline_cache_jit::compile_inline_cache(fixnum index,
					    cell generic_word_,
					    cell methods_,
					    cell cache_entries_,
					    bool tail_call_p)
{
	gc_root<word> generic_word(generic_word_,parent_vm);
	gc_root<array> methods(methods_,parent_vm);
	gc_root<array> cache_entries(cache_entries_,parent_vm);

	cell inline_cache_type = parent_vm->determine_inline_cache_type(cache_entries.untagged());
	parent_vm->update_pic_count(inline_cache_type);

	/* Generate machine code to determine the object's class. */
	emit_class_lookup(index,inline_cache_type);

	/* Generate machine code to check, in turn, if the class is one of the cached entries. */
	cell i;
	for(i = 0; i < array_capacity(cache_entries.untagged()); i += 2)
	{
		/* Class equal? */
		cell klass = array_nth(cache_entries.untagged(),i);
		emit_check(klass);

		/* Yes? Jump to method */
		cell method = array_nth(cache_entries.untagged(),i + 1);
		emit_with(parent_vm->userenv[PIC_HIT],method);
	}

	/* Generate machine code to handle a cache miss, which ultimately results in
	   this function being called again.

	   The inline-cache-miss primitive call receives enough information to
	   reconstruct the PIC. */
	push(generic_word.value());
	push(methods.value());
	push(tag_fixnum(index));
	push(cache_entries.value());
	word_special(parent_vm->userenv[tail_call_p ? PIC_MISS_TAIL_WORD : PIC_MISS_WORD]);
}

code_block *factor_vm::compile_inline_cache(fixnum index,cell generic_word_,cell methods_,cell cache_entries_,bool tail_call_p)
{
	gc_root<word> generic_word(generic_word_,this);
	gc_root<array> methods(methods_,this);
	gc_root<array> cache_entries(cache_entries_,this);

	inline_cache_jit jit(generic_word.value(),this);
	jit.compile_inline_cache(index,
				 generic_word.value(),
				 methods.value(),
				 cache_entries.value(),
				 tail_call_p);
	code_block *code = jit.to_code_block();
	relocate_code_block(code);
	return code;
}

/* A generic word's definition performs general method lookup. Allocates memory */
void *factor_vm::megamorphic_call_stub(cell generic_word)
{
	return untag<word>(generic_word)->xt;
}

cell factor_vm::inline_cache_size(cell cache_entries)
{
	return array_capacity(untag_check<array>(cache_entries)) / 2;
}

/* Allocates memory */
cell factor_vm::add_inline_cache_entry(cell cache_entries_, cell klass_, cell method_)
{
	gc_root<array> cache_entries(cache_entries_,this);
	gc_root<object> klass(klass_,this);
	gc_root<word> method(method_,this);

	cell pic_size = array_capacity(cache_entries.untagged());
	gc_root<array> new_cache_entries(reallot_array(cache_entries.untagged(),pic_size + 2),this);
	set_array_nth(new_cache_entries.untagged(),pic_size,klass.value());
	set_array_nth(new_cache_entries.untagged(),pic_size + 1,method.value());
	return new_cache_entries.value();
}

void factor_vm::update_pic_transitions(cell pic_size)
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
void *factor_vm::inline_cache_miss(cell return_address)
{
	check_code_pointer(return_address);

	/* Since each PIC is only referenced from a single call site,
	   if the old call target was a PIC, we can deallocate it immediately,
	   instead of leaving dead PICs around until the next GC. */
	deallocate_inline_cache(return_address);

	gc_root<array> cache_entries(dpop(),this);
	fixnum index = untag_fixnum(dpop());
	gc_root<array> methods(dpop(),this);
	gc_root<word> generic_word(dpop(),this);
	gc_root<object> object(((cell *)ds)[-index],this);

	void *xt;

	cell pic_size = inline_cache_size(cache_entries.value());

	update_pic_transitions(pic_size);

	if(pic_size >= max_pic_size)
		xt = megamorphic_call_stub(generic_word.value());
	else
	{
		cell klass = object_class(object.value());
		cell method = lookup_method(object.value(),methods.value());

		gc_root<array> new_cache_entries(add_inline_cache_entry(
							   cache_entries.value(),
							   klass,
							   method),this);
		xt = compile_inline_cache(index,
					  generic_word.value(),
					  methods.value(),
					  new_cache_entries.value(),
					  tail_call_site_p(return_address))->xt();
	}

	/* Install the new stub. */
	set_call_target(return_address,xt);

#ifdef PIC_DEBUG
	printf("Updated %s call site 0x%lx with 0x%lx\n",
	       tail_call_site_p(return_address) ? "tail" : "non-tail",
	       return_address,
	       (cell)xt);
#endif

	return xt;
}

VM_C_API void *inline_cache_miss(cell return_address, factor_vm *myvm)
{
	ASSERTVM();
	return VM_PTR->inline_cache_miss(return_address);
}

void factor_vm::primitive_reset_inline_cache_stats()
{
	cold_call_to_ic_transitions = ic_to_pic_transitions = pic_to_mega_transitions = 0;
	cell i;
	for(i = 0; i < 4; i++) pic_counts[i] = 0;
}

void factor_vm::primitive_inline_cache_stats()
{
	growable_array stats(this);
	stats.add(allot_cell(cold_call_to_ic_transitions));
	stats.add(allot_cell(ic_to_pic_transitions));
	stats.add(allot_cell(pic_to_mega_transitions));
	cell i;
	for(i = 0; i < 4; i++)
		stats.add(allot_cell(pic_counts[i]));
	stats.trim();
	dpush(stats.elements.value());
}

}
