bool gc_in_progress;

/* GC is off during heap walking */
bool heap_scan;

int64_t gc_time;

/* Given a pointer to oldspace, copy it to newspace. */
INLINE void* copy_untagged_object(void* pointer, CELL size)
{
	void* newpointer = allot(size);
	memcpy(newpointer,pointer,size);

	return newpointer;
}

CELL copy_object_impl(CELL pointer);

INLINE void copy_object(CELL* handle)
{
	CELL pointer = *handle;
	CELL tag;
	CELL header;
	CELL newpointer;

	if(pointer == F)
		return;

	tag = TAG(pointer);

	if(tag == FIXNUM_TYPE)
		return;

	if(headerp(pointer))
		critical_error("Asked to copy header",pointer);

	header = get(UNTAG(pointer));
	if(TAG(header) == GC_COLLECTED)
		newpointer = UNTAG(header);
	else
		newpointer = copy_object_impl(pointer);
	*handle = RETAG(newpointer,tag);
}

void collect_roots(void);
void primitive_gc(void);
void maybe_garbage_collection(void);
void primitive_gc_time(void);
