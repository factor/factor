CELL scan;
bool gc_in_progress;

void* copy_untagged_object(void* pointer, CELL size);
void copy_object(CELL* handle);
void collect_object(void);
void collect_next(void);
void collect_roots(void);
void primitive_gc(void);
