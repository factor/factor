namespace factor
{

CELL lookup_method(CELL object, CELL methods);
PRIMITIVE(lookup_method);

CELL object_class(CELL object);

PRIMITIVE(mega_cache_miss);

PRIMITIVE(reset_dispatch_stats);
PRIMITIVE(dispatch_stats);

void jit_emit_class_lookup(jit *jit, F_FIXNUM index, CELL type);

void jit_emit_mega_cache_lookup(jit *jit, CELL methods, F_FIXNUM index, CELL cache);

}
