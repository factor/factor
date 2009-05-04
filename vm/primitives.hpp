namespace factor
{

extern void *primitives[];

#define PRIMITIVE(name) extern "C" void primitive_##name()

}
