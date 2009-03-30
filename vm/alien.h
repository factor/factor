CELL allot_alien(CELL delegate, CELL displacement);

void primitive_displaced_alien(void);
void primitive_alien_address(void);

DLLEXPORT void *alien_offset(CELL object);

void fixup_alien(F_ALIEN* d);

DLLEXPORT void *unbox_alien(void);
DLLEXPORT void box_alien(void *ptr);

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
void primitive_alien_cell(void);
void primitive_set_alien_cell(void);

DLLEXPORT void to_value_struct(CELL src, void *dest, CELL size);
DLLEXPORT void box_value_struct(void *src, CELL size);
DLLEXPORT void box_small_struct(CELL x, CELL y, CELL size);
void box_medium_struct(CELL x1, CELL x2, CELL x3, CELL x4, CELL size);

DEFINE_UNTAG(F_DLL,DLL_TYPE,dll)

void primitive_dlopen(void);
void primitive_dlsym(void);
void primitive_dlclose(void);
void primitive_dll_validp(void);
