typedef struct {
	CELL header;
	void* ptr;
	bool expired;
} ALIEN;

INLINE ALIEN* untag_alien_fast(CELL tagged)
{
	return (ALIEN*)UNTAG(tagged);
}

typedef struct {
	CELL header;
	CELL alien;
	CELL displacement;
} DISPLACED_ALIEN;

INLINE DISPLACED_ALIEN* untag_displaced_alien_fast(CELL tagged)
{
	return (DISPLACED_ALIEN*)UNTAG(tagged);
}

void primitive_expired(void);
void primitive_alien(void);
void primitive_displaced_alien(void);
void primitive_alien_address(void);

void fixup_alien(ALIEN* alien);
void fixup_displaced_alien(DISPLACED_ALIEN* d);
void collect_displaced_alien(DISPLACED_ALIEN* d);

DLLEXPORT void* unbox_alien(void);
ALIEN* alien(void* ptr);
DLLEXPORT void box_alien(void* ptr);

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
void primitive_alien_c_string(void);
void primitive_set_alien_c_string(void);
