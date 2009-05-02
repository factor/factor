CELL max_pic_size;

CELL cold_call_to_ic_transitions;
CELL ic_to_pic_transitions;
CELL pic_to_mega_transitions;

/* PIC_TAG, PIC_HI_TAG, PIC_TUPLE, PIC_HI_TAG_TUPLE */
CELL pic_counts[4];

void init_inline_caching(int max_size);

void primitive_inline_cache_miss(void);

XT inline_cache_miss(CELL return_address);

void primitive_reset_inline_cache_stats(void);
void primitive_inline_cache_stats(void);
