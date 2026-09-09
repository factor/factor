/* XCreateIC consumes the arguments but returns NULL for a NULL input method. */
#include <X11/Xlib.h>
#include <stdio.h>
int main(void) {
    XIC ic = XCreateIC(NULL, XNClientWindow, (Window)0x12345678UL,
        XNFocusWindow, (Window)0x76543210UL,
        XNInputStyle, (XIMStyle)0x100000408UL,
        XNResourceName, "Factor", XNResourceClass, "Factor", (char *)NULL);
    printf("Headless system XCreateIC null-input-method control: %s\n", ic == NULL ? "PASS" : "FAIL");
    return ic != NULL;
}
