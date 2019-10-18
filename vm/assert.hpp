namespace factor { void abort(); }

#ifdef FACTOR_DEBUG
#define FACTOR_ASSERT(condition)                                               \
  ((condition)                                                                 \
       ? (void)0                                                               \
       : (::fprintf(stderr, "assertion \"%s\" failed: file \"%s\", line %d\n", \
                    #condition, __FILE__, __LINE__),                           \
          ::factor::abort()))
#else
#define FACTOR_ASSERT(condition) ((void)0)
#endif
