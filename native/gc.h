CELL scan;
bool gc_in_progress;
int64_t gc_time;

/* Given a pointer to oldspace, copy it to newspace. */
INLINE void* copy_untagged_object(void* pointer, CELL size)
{
	void* newpointer = allot(size);
	memcpy(newpointer,pointer,size);

	return newpointer;
}

void copy_object(CELL* handle);
void collect_object(void);
void collect_next(void);
void collect_roots(void);
void primitive_gc(void);
void maybe_garbage_collection(void);
void primitive_gc_time(void);
