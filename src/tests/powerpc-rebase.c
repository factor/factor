/* Execute the continuation rebase loop produced by an actual boot image. */
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>

int main(int argc, char **argv) {
    assert(argc == 2);
    FILE *image = fopen(argv[1], "rb");
    assert(image);
    assert(fseek(image, 0, SEEK_END) == 0);
    long length = ftell(image);
    assert(length > 0 && fseek(image, 0, SEEK_SET) == 0);
    unsigned char *bytes = malloc((size_t)length);
    assert(bytes && fread(bytes, 1, (size_t)length, image) == (size_t)length);
    fclose(image);
    const uint32_t prefix[] = {
#ifdef __powerpc64__
        0x7c243040, 0x40800018, 0xe8a40000,
        0x7ca42a14, 0xf8a40000, 0x7ca42b78,
#else
        0x7c043040, 0x40800018, 0x80a40000,
        0x7ca42a14, 0x90a40000, 0x7ca42b78,
#endif
    };
    const unsigned char *loop = NULL;
    for (size_t offset = 0; offset + 28 <= (size_t)length; ++offset) {
        if (memcmp(bytes + offset, prefix, sizeof(prefix)) == 0) {
            assert(loop == NULL);
            loop = bytes + offset;
        }
    }
    assert(loop);
    uint32_t *code = mmap(NULL, 4096, PROT_READ | PROT_WRITE,
                         MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    assert(code != MAP_FAILED);
    code[0] = 0x7c862378; /* mr r6,r4: bottom */
    code[1] = 0x7c641b78; /* mr r4,r3: cursor */
    memcpy(code + 2, loop, 28);
    code[9] = 0x4e800020; /* blr */
    assert(mprotect(code, 4096, PROT_READ | PROT_EXEC) == 0);
    __builtin___clear_cache((char *)code, (char *)(code + 10));
    typedef void (*entry_fn)(uintptr_t, uintptr_t);
#ifdef __powerpc64__
#if _CALL_ELF == 1
    uintptr_t descriptor[] = {(uintptr_t)code, 0, 0};
    entry_fn entry = (entry_fn)descriptor;
#else
    entry_fn entry = (entry_fn)code;
#endif
#else
    entry_fn entry = (entry_fn)code;
#endif
    uintptr_t frames[48] = {0};
    const size_t cells_per_frame = 16;
    const uintptr_t frame_bytes = cells_per_frame * sizeof(uintptr_t);
    for (size_t i = 0; i < 3; ++i) {
        frames[i * cells_per_frame] = frame_bytes;
        frames[i * cells_per_frame + 3] = 0x12340000 + i;
    }
    entry((uintptr_t)frames, (uintptr_t)(frames + 48));
    for (size_t i = 0; i < 3; ++i) {
        assert(frames[i * cells_per_frame] ==
               (uintptr_t)(frames + (i + 1) * cells_per_frame));
        assert(frames[i * cells_per_frame + 3] == 0x12340000 + i);
    }
    assert(munmap(code, 4096) == 0);
    free(bytes);
    puts("Actual boot-image continuation rebase loop passed for three frames");
    return 0;
}
