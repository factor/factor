typedef struct {
	CELL header;
	CELL alien;
	CELL displacement;
	bool expired;
} ALIEN;

INLINE ALIEN* untag_alien_fast(CELL tagged)
{
	return (ALIEN*)UNTAG(tagged);
}

ALIEN *make_alien(CELL delegate, CELL displacement);

void primitive_expired(void);
void primitive_displaced_alien(void);
void primitive_alien_address(void);

void* alien_offset(CELL object);

void primitive_alien_to_string(void);
void primitive_string_to_alien(void);

void fixup_alien(ALIEN* d);
void collect_alien(ALIEN* d);

DLLEXPORT void *unbox_alien(void);
DLLEXPORT void box_alien(CELL ptr);

void primitive_alien_signed_cell(void);
void primitive_set_alien_signed_cell(void);
void primitive_alien_unsigned_cell(void);
void primitive_set_alien_unsigned_cell(void);
void primitive_alien_signed_8(void);
void primitive_set_alien_signed_8(void);
void primitive_alien_unsigned_8(void);
void primitive_set_alien_unsigned_8(void);
void primitive_alien_signed_4(void);
void primitive_set_alien_signed_4(void);
void primitive_alien_unsigned_4(void);
void primitive_set_alien_unsigned_4(void);
void primitive_alien_signed_2(void);
void primitive_set_alien_signed_2(void);
void primitive_alien_unsigned_2(void);
void primitive_set_alien_unsigned_2(void);
void primitive_alien_signed_1(void);
void primitive_set_alien_signed_1(void);
void primitive_alien_unsigned_1(void);
void primitive_set_alien_unsigned_1(void);
void primitive_alien_float(void);
void primitive_set_alien_float(void);
void primitive_alien_double(void);
void primitive_set_alien_double(void);

void unbox_value_struct(void *dest, CELL size);
