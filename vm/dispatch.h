CELL megamorphic_cache_hits;
CELL megamorphic_cache_misses;

CELL lookup_method(CELL object, CELL methods);
void primitive_lookup_method(void);

CELL object_class(CELL object);

void primitive_mega_cache_miss(void);

void primitive_reset_dispatch_stats(void);
void primitive_dispatch_stats(void);

void jit_emit_class_lookup(F_JIT *jit, F_FIXNUM index, CELL type);

void jit_emit_mega_cache_lookup(F_JIT *jit, CELL methods, F_FIXNUM index, CELL cache);
