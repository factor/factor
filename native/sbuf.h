typedef struct {
	/* always tag_header(SBUF_TYPE) */
	CELL header;
	/* untagged */
	CELL top;
	/* tagged */
	CELL string;
} SBUF;

INLINE SBUF* untag_sbuf(CELL tagged)
{
	type_check(SBUF_TYPE,tagged);
	return (SBUF*)UNTAG(tagged);
}

SBUF* sbuf(FIXNUM capacity);

void primitive_sbuf(void);
void primitive_sbuf_length(void);
void primitive_set_sbuf_length(void);
void primitive_sbuf_nth(void);
void sbuf_ensure_capacity(SBUF* sbuf, FIXNUM top);
void set_sbuf_nth(SBUF* sbuf, CELL index, uint16_t value);
void primitive_set_sbuf_nth(void);
void sbuf_append_string(SBUF* sbuf, STRING* string);
void primitive_sbuf_append(void);
void primitive_sbuf_to_string(void);
void primitive_sbuf_reverse(void);
void primitive_sbuf_clone(void);
bool sbuf_eq(SBUF* s1, SBUF* s2);
void primitive_sbuf_eq(void);
void primitive_sbuf_hashcode(void);
void fixup_sbuf(SBUF* sbuf);
void collect_sbuf(SBUF* sbuf);
