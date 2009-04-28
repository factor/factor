int max_pic_size;

void primitive_inline_cache_miss(void);

F_FASTCALL XT inline_cache_miss(CELL return_address);

CELL object_class(CELL object);
CELL lookup_method(CELL object, CELL methods);
