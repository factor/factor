//typedef extern "C" void (*F_PRIMITIVE)(void);

extern void *primitives[];

#define PRIMITIVE(name) extern "C" void primitive_##name()
