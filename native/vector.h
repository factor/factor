typedef struct {
	/* always tag_header(VECTOR_TYPE) */
	CELL header;
	/* untagged */
	CELL top;
	/* untagged */
	ARRAY* array;
} VECTOR;

INLINE VECTOR* untag_vector(CELL tagged)
{
	type_check(VECTOR_TYPE,tagged);
	return (VECTOR*)UNTAG(tagged);
}

VECTOR* vector(FIXNUM capacity);

void primitive_vector(void);
void primitive_vector_length(void);
void primitive_set_vector_length(void);
void primitive_vector_nth(void);
void vector_ensure_capacity(VECTOR* vector, CELL index);
void primitive_set_vector_nth(void);
void fixup_vector(VECTOR* vector);
void collect_vector(VECTOR* vector);
