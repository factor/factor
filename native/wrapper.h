typedef struct {
	CELL header;
	CELL object;
} F_WRAPPER;

INLINE F_WRAPPER* untag_wrapper_fast(CELL tagged)
{
	return (F_WRAPPER*)UNTAG(tagged);
}

void primitive_wrapper(void);
void fixup_wrapper(F_WRAPPER* wrapper);
void collect_wrapper(F_WRAPPER* wrapper);
