typedef __SIZE_TYPE__ size_t;
typedef __builtin_va_list va_list;
extern int vsnprintf(char *, size_t, const char *, va_list);
__declspec(dllexport) int direct_vsnprintf(char *out, size_t size,
                                         const char *format, va_list args) {
    return vsnprintf(out, size, format, args);
}
