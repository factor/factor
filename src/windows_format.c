// Zig's LLVM backend does not support Windows va_list yet. Keep the locale
// formatting bridge fixed-arity on the Zig side and let C handle varargs.
#include <stdio.h>
#include <locale.h>

int factor_windows_format_float(char *buffer, size_t length, const char *format,
                                _locale_t locale, int precision, double value) {
    return _snprintf_l(buffer, length, format, locale, precision, value);
}
