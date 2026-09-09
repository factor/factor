/* SDK-free link-contract model of UCRT's header-defined vsnprintf wrapper.
 * The permanent Factor test uses the actual fixture getter and native CRT. */
typedef __SIZE_TYPE__ size_t;
typedef __builtin_va_list va_list;
typedef int (*vsnprintf_function)(char *, size_t, const char *, va_list);
__declspec(dllimport) int __stdio_common_vsprintf(
    unsigned long long, char *, size_t, const char *, void *, va_list);
static int header_vsnprintf(char *out, size_t size,
                           const char *format, va_list args) {
    int result = __stdio_common_vsprintf(2, out, size, format, 0, args);
    return result < 0 ? -1 : result;
}
__declspec(dllexport) __declspec(noinline)
vsnprintf_function va_vsnprintf_pointer(void) { return header_vsnprintf; }
__declspec(dllexport) int indirect_vsnprintf(char *out, size_t size,
                                           const char *format, va_list args) {
    return va_vsnprintf_pointer()(out, size, format, args);
}
