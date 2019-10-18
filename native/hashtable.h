typedef struct {
	/* always tag_header(HASHTABLE_TYPE) */
	CELL header;
	/* tagged */
	CELL count;
        /* tagged */
        CELL deleted;
	/* tagged */
	CELL array;
} F_HASHTABLE;

void primitive_hashtable(void);
void fixup_hashtable(F_HASHTABLE* hashtable);
void collect_hashtable(F_HASHTABLE* hashtable);
