namespace factor
{

extern cell max_pic_size;

void init_inline_caching(int max_size);

PRIMITIVE(reset_inline_cache_stats);
PRIMITIVE(inline_cache_stats);
PRIMITIVE(inline_cache_miss);

extern "C" void *inline_cache_miss(cell return_address);

}
