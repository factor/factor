typedef struct {
	/* always tag_header(VECTOR_TYPE) */
	CELL header;
	/* untagged */
	CELL top;
	/* tagged */
	CELL array;
} F_VECTOR;

INLINE F_VECTOR* untag_vector(CELL tagged)
{
	type_check(VECTOR_TYPE,tagged);
	return (F_VECTOR*)UNTAG(tagged);
}

F_VECTOR* vector(F_FIXNUM capacity);

void primitive_vector(void);
void primitive_to_vector(void);
void fixup_vector(F_VECTOR* vector);
void collect_vector(F_VECTOR* vector);
