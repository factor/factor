/* Execute actual image save/restore instructions across a native home writer. */
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>

/* PPC64 variadic calls require caller register homes. GNU32 SysV does not. */
extern void factor_powerpc_clobber_signal_homes(uintptr_t, ...);

static uint32_t word(const unsigned char *p) {
    uint32_t result;
    memcpy(&result, p, 4);
    return result;
}
static uint32_t load(unsigned reg, unsigned offset) {
#ifdef __powerpc64__
    return 0xe8010000 | reg << 21 | offset;
#else
    return 0x80010000 | reg << 21 | offset;
#endif
}
static void immediate(uint32_t **out, unsigned reg, uintptr_t value) {
#ifdef __powerpc64__
    *(*out)++ = 0x3c000000 | reg << 21 | (value >> 48 & 0xffff);
    *(*out)++ = 0x60000000 | reg << 21 | reg << 16 | (value >> 32 & 0xffff);
    *(*out)++ = 0x780007c6 | reg << 21 | reg << 16; /* sldi reg,reg,32 */
    *(*out)++ = 0x64000000 | reg << 21 | reg << 16 | (value >> 16 & 0xffff);
#else
    *(*out)++ = 0x3c000000 | reg << 21 | (value >> 16 & 0xffff);
#endif
    *(*out)++ = 0x60000000 | reg << 21 | reg << 16 | (value & 0xffff);
}

int main(int argc, char **argv) {
    assert(argc == 2);
    FILE *file = fopen(argv[1], "rb");
    assert(file && fseek(file, 0, SEEK_END) == 0);
    long length = ftell(file);
    assert(length > 0 && fseek(file, 0, SEEK_SET) == 0);
    unsigned char *image = malloc((size_t)length);
    assert(image && fread(image, 1, (size_t)length, file) == (size_t)length);
    fclose(file);
    const unsigned char *save = NULL, *restore = NULL, *restore_end = NULL;
    unsigned frame = 0, gprs = 0, fpscr = 0;
    size_t save_bytes = 0;
    for (size_t i = 0; i + 1024 < (size_t)length; ++i) {
        uint32_t first = word(image + i), second = word(image + i + 4);
#ifdef __powerpc64__
        if ((first & 0xffff0003) != 0xf8210001 || (second & 0xffff0000) != 0xf8010000) continue;
        unsigned size = (unsigned)-(int16_t)(first & 0xfffc);
#else
        if ((first & 0xffff0000) != 0x94210000 || (second & 0xffff0000) != 0x90010000) continue;
        unsigned size = (unsigned)-(int16_t)first;
#endif
        unsigned base = second & 0xffff;
        if (!((size == 640 && base == 32) || (size == 672 && base == 112))) continue;
        unsigned status = base + 544;
        const unsigned char *end = image + i + 4;
        while (end < image + i + 512 && word(end) != (0xd8010000 | status)) end += 4;
        assert(end < image + i + 512);
        end += 4;
        const unsigned char *call = end;
        while (call < image + i + 640 && word(call) != 0x4e800421) call += 4;
        assert(call < image + i + 640);
        const unsigned char *tail = call + 4;
        assert(word(tail) == (0xc8010000 | status));
        const unsigned char *tail_end = tail;
        unsigned lr = sizeof(uintptr_t) == 8 ? 16 : 4;
        while (tail_end < tail + 512 && word(tail_end) != load(0, size + lr)) tail_end += 4;
        assert(tail_end < tail + 512);
        if (save) {
            assert(frame == size && gprs == base && save_bytes == (size_t)(end - image - i));
            assert(memcmp(save, image + i, save_bytes) == 0);
        } else {
            save = image + i; restore = tail; restore_end = tail_end;
            frame = size; gprs = base; fpscr = status;
            save_bytes = (size_t)(end - save);
        }
    }
    assert(save && restore && restore_end && fpscr < frame);
    uint32_t *code = mmap(NULL, 4096, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    assert(code != MAP_FAILED);
    /* Omit VM-specific context publication. Keep the producer's entire save
       prefix and restore tail, replacing its native call and final synthetic
       continuation transfer with a native home writer and a C return. */
    memcpy(code, save, save_bytes);
    uint32_t *out = code + save_bytes / 4;
    immediate(&out, 12, (uintptr_t)factor_powerpc_clobber_signal_homes);
#if defined(__powerpc64__) && _CALL_ELF == 1
    *out++ = 0xe84c0008; /* ld r2,8(r12): native TOC */
    *out++ = 0xe98c0000; /* ld r12,0(r12): native entry */
#endif
    *out++ = 0x4cc63182; /* crclr 6: variadic call has no FP arguments */
    *out++ = 0x7d8903a6; /* mtctr r12 */
    *out++ = 0x4e800421; /* bctrl */
    memcpy(out, restore, (size_t)(restore_end - restore));
    out += (restore_end - restore) / 4;
    uint32_t *result_insn = out;
    *out++ = 0x7c431378; /* mr r3,r2: expose saved r2 before caller TOC reload */
    *out++ = load(0, gprs);
    *out++ = load(1, 0);
    *out++ = 0x4e800020;
    assert(mprotect(code, 4096, PROT_READ | PROT_EXEC) == 0);
    __builtin___clear_cache((char *)code, (char *)out);
    uintptr_t original_r2;
    __asm__ volatile("mr %0,2" : "=r"(original_r2));
    typedef uintptr_t (*integer_fn)(uintptr_t);
#if defined(__powerpc64__) && _CALL_ELF == 1
    /* The ELFv1 backend introduces descriptor reads after GCC's store DCE;
       volatile keeps this deliberately constructed local descriptor live. */
    volatile uintptr_t descriptor[] = {(uintptr_t)code, original_r2, 0};
    integer_fn entry = (integer_fn)descriptor;
#else
    integer_fn entry = (integer_fn)code;
#endif
    uintptr_t returned = entry(0x12345678);
    __asm__ volatile("mr 2,%0" : : "r"(original_r2));
    assert(returned == original_r2);
    assert(mprotect(code, 4096, PROT_READ | PROT_WRITE) == 0);
    *result_insn = 0x60000000; /* nop: keep restored r3 and f1 */
    assert(mprotect(code, 4096, PROT_READ | PROT_EXEC) == 0);
    __builtin___clear_cache((char *)code, (char *)out);
    assert(entry(0x12345678) == 0x12345678);
    typedef double (*floating_fn)(double);
    assert(((floating_fn)(uintptr_t)entry)(123.25) == 123.25);
    assert(munmap(code, 4096) == 0);
    free(image);
    puts("Actual image signal saves survived native ABI scratch area and FPR clobber");
    return 0;
}
