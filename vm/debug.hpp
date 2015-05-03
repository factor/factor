namespace factor {

extern bool factor_print_p;

}

#ifdef FACTOR_DEBUG

#define FACTOR_PRINT(x)                                          \
  do {                                                           \
    if (factor_print_p) {                                        \
      std::cerr                                                  \
          << std::setw(28) << std::left << __FILE__              \
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
