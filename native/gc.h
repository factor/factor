CELL scan;

CELL copy_untagged_object(CELL pointer, CELL size);
void copy_object(CELL* handle);
void collect_object(void);
void collect_next(void);
void collect_roots(void);
void primitive_gc(void);
