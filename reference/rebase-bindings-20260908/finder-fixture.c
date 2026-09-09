#include <stdio.h>
#include <stdlib.h>
__attribute__((constructor)) static void announce_load(void) {
    const char *path = getenv("FACTOR_FINDER_MARKER");
    if (path) { FILE *f = fopen(path, "w"); if (f) { fputs("loaded", f); fclose(f); } }
}
int factor_finder_control(void) { return 97; }
