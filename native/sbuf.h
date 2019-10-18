typedef struct {
	/* always tag_header(SBUF_TYPE) */
	CELL header;
	/* tagged */
	CELL top;
	/* tagged */
	CELL string;
} F_SBUF;

INLINE CELL sbuf_capacity(F_SBUF* sbuf)
{
	return untag_fixnum_fast(sbuf->top);
}

INLINE F_SBUF* untag_sbuf(CELL tagged)
{
	type_check(SBUF_TYPE,tagged);
	return (F_SBUF*)UNTAG(tagged);
}

F_SBUF* sbuf(F_FIXNUM capacity);

void primitive_sbuf(void);
void primitive_sbuf_to_string(void);
void fixup_sbuf(F_SBUF* sbuf);
void collect_sbuf(F_SBUF* sbuf);
