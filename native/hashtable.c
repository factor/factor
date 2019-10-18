#include "factor.h"

void primitive_hashtable(void)
{
	F_HASHTABLE* hash;
	maybe_gc(0);
	hash = allot_object(HASHTABLE_TYPE,sizeof(F_HASHTABLE));
	hash->count = F;
	hash->deleted = F;
	hash->array = F;
	dpush(tag_object(hash));
}

void fixup_hashtable(F_HASHTABLE* hashtable)
{
	data_fixup(&hashtable->count);
	data_fixup(&hashtable->deleted);
	data_fixup(&hashtable->array);
}

void collect_hashtable(F_HASHTABLE* hashtable)
{
	copy_handle(&hashtable->count);
	copy_handle(&hashtable->deleted);
	copy_handle(&hashtable->array);
}
