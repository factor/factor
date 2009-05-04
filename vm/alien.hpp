namespace factor
{

cell allot_alien(cell delegate, cell displacement);

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

VM_C_API char *alien_offset(cell object);
VM_C_API char *unbox_alien(void);
VM_C_API void box_alien(void *ptr);
VM_C_API void to_value_struct(cell src, void *dest, cell size);
VM_C_API void box_value_struct(void *src, cell size);
VM_C_API void box_small_struct(cell x, cell y, cell size);
VM_C_API void box_medium_struct(cell x1, cell x2, cell x3, cell x4, cell size);

}
