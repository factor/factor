namespace factor
{

extern cell megamorphic_cache_hits;
extern cell megamorphic_cache_misses;

cell lookup_method(cell object, cell methods);
PRIMITIVE(lookup_method);

cell object_class(cell object);

PRIMITIVE(mega_cache_miss);

PRIMITIVE(reset_dispatch_stats);
PRIMITIVE(dispatch_stats);

void jit_emit_class_lookup(jit *jit, fixnum index, cell type);

void jit_emit_mega_cache_lookup(jit *jit, cell methods, fixnum index, cell cache);

}
