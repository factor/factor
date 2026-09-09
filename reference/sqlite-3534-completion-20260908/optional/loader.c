#include <dlfcn.h>
#include <stdio.h>
#include <string.h>

int main(int argc, char **argv) {
    if (argc != 2) return 2;
    void *system = dlopen("libsqlite3.so.0", RTLD_NOW | RTLD_GLOBAL);
    void *fixture = dlopen(argv[1], RTLD_NOW | RTLD_LOCAL);
    if (!system || !fixture) { fprintf(stderr, "%s\n", dlerror()); return 1; }
    const char *(*version)(void) = dlsym(fixture, "sqlite3_libversion");
    if (!version) return 1;
    printf("SQLite fixture version with system SQLite loaded: %s\n", version());
    int result = strcmp(version(), "3.53.4") != 0;
    dlclose(fixture);
    dlclose(system);
    return result;
}
