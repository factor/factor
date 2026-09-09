#include "raylib.h"
#include <stdarg.h>
#include <stdio.h>
#include <string.h>

static int callback_ok;
static void capture(int level, const char *format, va_list args)
{
    char output[64];
    int count = vsnprintf(output, sizeof output, format, args);
    callback_ok = level == LOG_INFO && count == 6 && !strcmp(output, "7/2.50");
}

int main(void)
{
    if (strcmp(TextFormat("literal 100%%"), "literal 100%")) return 1;
    if (strcmp(TextFormat("%d/%.2f/%d/%.1f/%d", 7, 2.5, -3, 4.5, 11),
               "7/2.50/-3/4.5/11")) return 2;
    SetTraceLogLevel(LOG_ALL);
    SetTraceLogCallback(capture);
    TraceLog(LOG_INFO, "%d/%.2f", 7, 2.5);
    SetTraceLogCallback(NULL);
    if (!callback_ok) return 3;
    puts("Raylib 6.0 C formatting and va_list callback controls passed");
    return 0;
}
