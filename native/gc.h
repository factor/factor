CELL scan;
bool gc_in_progress;
long long gc_time;

void* copy_untagged_object(void* pointer, CELL size);
void copy_object(CELL* handle);
void collect_object(void);
void collect_next(void);
void collect_roots(void);
void primitive_gc(void);
void maybe_garbage_collection(void);
void primitive_gc_time(void);
