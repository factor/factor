/* Headless ABI oracles matching the Xlib and GTK2 variadic prototypes. */
#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>
typedef void *XIM;
typedef void *XIC;
typedef unsigned long Window;
typedef unsigned long XIMStyle;
static const unsigned long window1 = 0x12345678UL;
static const unsigned long window2 = 0x76543210UL;
static const unsigned long style = sizeof(unsigned long) == 8 ? 0x100000408UL : 0x408UL;

XIC XCreateIC(XIM im, ...) {
    va_list ap;
    va_start(ap, im);
    const char *key1 = va_arg(ap, const char *);
    Window value1 = va_arg(ap, Window);
    const char *key2 = va_arg(ap, const char *);
    Window value2 = va_arg(ap, Window);
    const char *key3 = va_arg(ap, const char *);
    XIMStyle value3 = va_arg(ap, XIMStyle);
    const char *key4 = va_arg(ap, const char *);
    const char *value4 = va_arg(ap, const char *);
    const char *key5 = va_arg(ap, const char *);
    const char *value5 = va_arg(ap, const char *);
    void *sentinel = va_arg(ap, void *);
    va_end(ap);
    /* Never dereference anonymous pointers: incorrect baseline placement can
       supply arbitrary values. Fixed numeric fields identify correct traversal. */
    return !im && key1 && key2 && key3 && key4 && key5 && value4 && value5 &&
        value1 == window1 && value2 == window2 && value3 == style && !sentinel
        ? (XIC)(uintptr_t)0x1234 : NULL;
}

void *gtk_file_chooser_dialog_new(const char *title, void *parent, int action,
                                 const char *first_button_text, ...) {
    va_list ap;
    va_start(ap, first_button_text);
    int first_response = va_arg(ap, int);
    const char *second_button = va_arg(ap, const char *);
    int second_response = va_arg(ap, int);
    void *sentinel = va_arg(ap, void *);
    va_end(ap);
    return title && !parent && action == 1 && first_button_text &&
        first_response == -6 && second_button && second_response == -3 && !sentinel
        ? (void *)(uintptr_t)0x5678 : NULL;
}

#ifdef ORACLE_MAIN
int main(void) {
    int x = XCreateIC(NULL, "clientWindow", window1, "focusWindow", window2,
        "inputStyle", style, "resourceName", "Factor", "resourceClass", "Factor",
        (void *)NULL) == (XIC)(uintptr_t)0x1234;
    int gtk = gtk_file_chooser_dialog_new("Choose", NULL, 1, "Cancel", -6,
        "Open", -3, (void *)NULL) == (void *)(uintptr_t)0x5678;
    printf("XCreateIC C varargs control: %s\nGTK2 chooser C varargs control: %s\n",
        x ? "PASS" : "FAIL", gtk ? "PASS" : "FAIL");
    return !(x && gtk);
}
#endif
