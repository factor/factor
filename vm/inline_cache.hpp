namespace factor
{
PRIMITIVE(reset_inline_cache_stats);
PRIMITIVE(inline_cache_stats);
PRIMITIVE(inline_cache_miss);
PRIMITIVE(inline_cache_miss_tail);

VM_C_API void *inline_cache_miss(cell return_address, factorvm *vm);

}
