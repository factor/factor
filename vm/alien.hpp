CELL allot_alien(CELL delegate, CELL displacement);

PRIMITIVE(displaced_alien);
PRIMITIVE(alien_address);

PRIMITIVE(alien_signed_cell);
PRIMITIVE(set_alien_signed_cell);
PRIMITIVE(alien_unsigned_cell);
PRIMITIVE(set_alien_unsigned_cell);
PRIMITIVE(alien_signed_8);
PRIMITIVE(set_alien_signed_8);
PRIMITIVE(alien_unsigned_8);
PRIMITIVE(set_alien_unsigned_8);
PRIMITIVE(alien_signed_4);
PRIMITIVE(set_alien_signed_4);
PRIMITIVE(alien_unsigned_4);
PRIMITIVE(set_alien_unsigned_4);
PRIMITIVE(alien_signed_2);
PRIMITIVE(set_alien_signed_2);
PRIMITIVE(alien_unsigned_2);
PRIMITIVE(set_alien_unsigned_2);
PRIMITIVE(alien_signed_1);
PRIMITIVE(set_alien_signed_1);
PRIMITIVE(alien_unsigned_1);
PRIMITIVE(set_alien_unsigned_1);
PRIMITIVE(alien_float);
PRIMITIVE(set_alien_float);
PRIMITIVE(alien_double);
PRIMITIVE(set_alien_double);
PRIMITIVE(alien_cell);
PRIMITIVE(set_alien_cell);

PRIMITIVE(dlopen);
PRIMITIVE(dlsym);
PRIMITIVE(dlclose);
PRIMITIVE(dll_validp);

VM_C_API char *alien_offset(CELL object);
VM_C_API char *unbox_alien(void);
VM_C_API void box_alien(void *ptr);
VM_C_API void to_value_struct(CELL src, void *dest, CELL size);
VM_C_API void box_value_struct(void *src, CELL size);
VM_C_API void box_small_struct(CELL x, CELL y, CELL size);
VM_C_API void box_medium_struct(CELL x1, CELL x2, CELL x3, CELL x4, CELL size);
