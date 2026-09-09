#include <curses.h>
#include <term.h>
#include <stdio.h>
#include <string.h>

int main(void) {
    FILE *out = tmpfile(), *in = tmpfile();
    if (!out || !in) return 1;
    SCREEN *screen = newterm("factor-ffi-test", out, in);
    if (!screen) return 1;
    char *capability = tigetstr("pfkey");
    if (!capability || capability == (char *)-1) return 1;
    char *text = tparm(capability, 7L, "text");
    int result = !text || strcmp(text, "7:text");
    printf("C tparm from terminfo: %s\n", text ? text : "(null)");
    endwin(); delscreen(screen); fclose(out); fclose(in);
    return result;
}
