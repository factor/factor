namespace factor
{

extern "C" typedef void (*primitive_type)();
extern const primitive_type primitives[];

#define PRIMITIVE(name) extern "C" void primitive_##name()

}
