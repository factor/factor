namespace factor
{

#if defined(FACTOR_X86)
  extern "C" __attribute__ ((regparm (1))) typedef void (*primitive_type)(void *myvm);
  #define PRIMITIVE(name) extern "C" __attribute__ ((regparm (1)))  void primitive_##name(void *myvm)
#else
  extern "C" typedef void (*primitive_type)(void *myvm);
  #define PRIMITIVE(name) extern "C" void primitive_##name(void *myvm)
#endif

extern const primitive_type primitives[];
}
