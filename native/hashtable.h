typedef struct {
	/* always tag_header(HASHTABLE_TYPE) */
	CELL header;
	/* tagged */
	CELL count;
	/* tagged */
	CELL array;
} F_HASHTABLE;

F_HASHTABLE* hashtable(F_FIXNUM capacity);

void primitive_hashtable(void);
void primitive_to_hashtable(void);
void fixup_hashtable(F_HASHTABLE* hashtable);
void collect_hashtable(F_HASHTABLE* hashtable);
