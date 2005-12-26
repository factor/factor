typedef struct {
	/* always tag_header(SBUF_TYPE) */
	CELL header;
	/* tagged */
	CELL top;
	/* tagged */
	CELL string;
} F_SBUF;

F_SBUF* sbuf(F_FIXNUM capacity);
void primitive_sbuf(void);
void fixup_sbuf(F_SBUF* sbuf);
void collect_sbuf(F_SBUF* sbuf);
