namespace factor
{

extern "C" typedef void (*primitive_type)(factor_vm *parent);
#define PRIMITIVE(name) extern "C" void primitive_##name(factor_vm *parent)
#define PRIMITIVE_FORWARD(name) extern "C" void primitive_##name(factor_vm *parent) \
{ \
	parent->primitive_##name(); \
}

extern const primitive_type primitives[];

/* These are generated with macros in alien.c */
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

}
