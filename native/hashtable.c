#include "factor.h"

F_HASHTABLE* hashtable(F_FIXNUM capacity)
{
	F_HASHTABLE* hash;
	if(capacity < 0)
		general_error(ERROR_NEGATIVE_ARRAY_SIZE,tag_fixnum(capacity));
	hash = allot_object(HASHTABLE_TYPE,sizeof(F_VECTOR));
	hash->count = tag_fixnum(0);
	hash->array = tag_object(array(ARRAY_TYPE,capacity,F));
	return hash;
}

void primitive_hashtable(void)
{
	maybe_garbage_collection();
	drepl(tag_object(hashtable(to_fixnum(dpeek()))));
}

void primitive_to_hashtable(void)
{
	type_check(HASHTABLE_TYPE,dpeek());
}

void fixup_hashtable(F_HASHTABLE* hashtable)
{
	data_fixup(&hashtable->array);
}

void collect_hashtable(F_HASHTABLE* hashtable)
{
	copy_object(&hashtable->array);
}
