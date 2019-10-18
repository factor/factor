namespace factor {

extern bool factor_print_p;

#ifdef FACTOR_DEBUG

// To chop the directory path of the __FILE__ macro.
inline const char* abbrev_path(const char* path) {
  const char* p1 = strrchr(path, '\\');
  const char* p2 = strrchr(path, '/');
  return (p1 > p2 ? p1 : p2) + 1;
}

#define FACTOR_PRINT(x)                                          \
  do {                                                           \
    if (factor_print_p) {                                        \
      std::cerr                                                  \
          << std::setw(16) << std::left << abbrev_path(__FILE__) \
          << " " << std::setw(4) << std::right << __LINE__       \
          << " " << std::setw(20) << std::left << __FUNCTION__   \
          << " " << x                                            \
          << std::endl;                                          \
    }                                                            \
  } while (0)
#define FACTOR_PRINT_MARK FACTOR_PRINT("")

#else
#define FACTOR_PRINT(fmt, ...) ((void)0)
#define FACTOR_PRINT_MARK ((void)0)
#endif

}
