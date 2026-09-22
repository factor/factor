#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <stdio.h>

/* Run the matching-architecture executable against an absolute DLL path. */
int main(int argc, char **argv)
{
    if (argc < 2 || argc > 3) {
        fprintf(stderr, "usage: check-dll DLL [export]\n");
        return 2;
    }
    HMODULE library = LoadLibraryExA(argv[1], NULL,
        LOAD_LIBRARY_SEARCH_DLL_LOAD_DIR | LOAD_LIBRARY_SEARCH_DEFAULT_DIRS);
    if (!library) {
        fprintf(stderr, "LOAD FAILED %s: Windows error %lu\n", argv[1], GetLastError());
        return 1;
    }
    if (argc == 3 && !GetProcAddress(library, argv[2])) {
        fprintf(stderr, "EXPORT MISSING %s: %s\n", argv[1], argv[2]);
        FreeLibrary(library);
        return 1;
    }
    printf("PASS %s\n", argv[1]);
    FreeLibrary(library);
    return 0;
}
