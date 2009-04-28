CELL megamorphic_cache_hits;
CELL megamorphic_cache_misses;

void primitive_lookup_method(void);

CELL object_class(CELL object);
CELL lookup_method(CELL object, CELL methods);

void primitive_reset_dispatch_stats(void);
void primitive_dispatch_stats(void);
