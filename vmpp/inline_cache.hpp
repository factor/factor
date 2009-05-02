extern CELL max_pic_size;

void init_inline_caching(int max_size);

void primitive_reset_inline_cache_stats(void);
void primitive_inline_cache_stats(void);

extern "C" XT inline_cache_miss(CELL return_address);
