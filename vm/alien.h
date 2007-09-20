CELL allot_alien(CELL delegate, CELL displacement);

DECLARE_PRIMITIVE(displaced_alien);
DECLARE_PRIMITIVE(alien_address);

DLLEXPORT void *alien_offset(CELL object);

void fixup_alien(F_ALIEN* d);

DLLEXPORT void *unbox_alien(void);
DLLEXPORT void box_alien(void *ptr);

DECLARE_PRIMITIVE(alien_signed_cell);
DECLARE_PRIMITIVE(set_alien_signed_cell);
DECLARE_PRIMITIVE(alien_unsigned_cell);
DECLARE_PRIMITIVE(set_alien_unsigned_cell);
DECLARE_PRIMITIVE(alien_signed_8);
DECLARE_PRIMITIVE(set_alien_signed_8);
DECLARE_PRIMITIVE(alien_unsigned_8);
DECLARE_PRIMITIVE(set_alien_unsigned_8);
DECLARE_PRIMITIVE(alien_signed_4);
DECLARE_PRIMITIVE(set_alien_signed_4);
DECLARE_PRIMITIVE(alien_unsigned_4);
DECLARE_PRIMITIVE(set_alien_unsigned_4);
DECLARE_PRIMITIVE(alien_signed_2);
DECLARE_PRIMITIVE(set_alien_signed_2);
DECLARE_PRIMITIVE(alien_unsigned_2);
DECLARE_PRIMITIVE(set_alien_unsigned_2);
DECLARE_PRIMITIVE(alien_signed_1);
DECLARE_PRIMITIVE(set_alien_signed_1);
DECLARE_PRIMITIVE(alien_unsigned_1);
DECLARE_PRIMITIVE(set_alien_unsigned_1);
DECLARE_PRIMITIVE(alien_float);
DECLARE_PRIMITIVE(set_alien_float);
DECLARE_PRIMITIVE(alien_double);
DECLARE_PRIMITIVE(set_alien_double);
DECLARE_PRIMITIVE(alien_cell);
DECLARE_PRIMITIVE(set_alien_cell);

DLLEXPORT void to_value_struct(CELL src, void *dest, CELL size);
DLLEXPORT void box_value_struct(void *src, CELL size);
DLLEXPORT void box_small_struct(CELL x, CELL y, CELL size);

INLINE F_DLL *untag_dll(CELL tagged)
{
	type_check(DLL_TYPE,tagged);
	return (F_DLL*)UNTAG(tagged);
}

DECLARE_PRIMITIVE(dlopen);
DECLARE_PRIMITIVE(dlsym);
DECLARE_PRIMITIVE(dlclose);
