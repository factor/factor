/* Execute exported ordinary/variadic Factor callback bytes on s390x Linux.
 * The synthetic Factor word deliberately clobbers Factor stack registers and
 * nonvolatile FPRs, then returns through the template's native restoration. */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>

static unsigned char offsets[6], captured[512], overflow[16];
static size_t frame_size;
static uintptr_t saved_sp;

__attribute__((noinline, used)) void capture_body(unsigned char *context) {
    memcpy(&saved_sp, context + offsets[2], sizeof(saved_sp));
    memcpy(captured, (void *)saved_sp, frame_size);
    if (frame_size == 512) {
        uintptr_t cursor;
        memcpy(&cursor, captured + 496, sizeof(cursor));
        memcpy(overflow, (void *)cursor, sizeof(overflow));
    }
}

extern uintptr_t capture_word(void);
__asm__(
    ".text\n.global capture_word\n.type capture_word,@function\n"
    "capture_word:\n"
    "stg %r14,8(%r15)\nlgr %r2,%r8\nbrasl %r14,capture_body\n"
    "lg %r14,8(%r15)\n"
    "lghi %r6,1001\nlghi %r7,1002\n"
    "lghi %r10,1003\nlghi %r11,1004\nlghi %r12,1005\nlghi %r13,1006\n"
    "lzdr %f8\nlzdr %f9\nlzdr %f10\nlzdr %f11\n"
    "lzdr %f12\nlzdr %f13\nlzdr %f14\nlzdr %f15\n"
    "lghi %r2,42\nbr %r14\n.size capture_word,.-capture_word\n");

static size_t read_file(const char *name, void *data, size_t capacity) {
    FILE *file = fopen(name, "rb");
    if (!file) { perror(name); exit(1); }
    size_t length = fread(data, 1, capacity, file);
    fclose(file);
    return length;
}
static uint32_t be32(const unsigned char *p) {
    return (uint32_t)p[0] << 24 | (uint32_t)p[1] << 16 |
           (uint32_t)p[2] << 8 | p[3];
}
static void put_be32(unsigned char *p, uint32_t n) {
    p[0] = n >> 24; p[1] = n >> 16; p[2] = n >> 8; p[3] = n;
}
static uintptr_t cell_at(size_t offset) {
    uintptr_t value; memcpy(&value, captured + offset, sizeof(value)); return value;
}
static void put_cell(void *base, size_t offset, uintptr_t value) {
    memcpy((unsigned char *)base + offset, &value, sizeof(value));
}
typedef uintptr_t (*callback)(uintptr_t, uintptr_t, uintptr_t, uintptr_t,
                             uintptr_t, double, double, double, double, ...);

static int probe(int variadic) {
    unsigned char vm[64] = {0}, original_context[128] = {0}, context[128] = {0};
    _Alignas(16) unsigned char factor_stack[16384], data_stack[128], retain_stack[128];
    uintptr_t safepoint = 0;
    put_cell(vm, offsets[0], (uintptr_t)original_context);
    put_cell(vm, offsets[1], (uintptr_t)context);
    put_cell(context, offsets[3], (uintptr_t)(factor_stack + 8192));
    put_cell(context, offsets[4], (uintptr_t)data_stack);
    put_cell(context, offsets[5], (uintptr_t)retain_stack);
    uintptr_t values[] = {(uintptr_t)vm, (uintptr_t)&safepoint, 0, 0, 0, 0,
                          (uintptr_t)capture_word};
    unsigned char *code = mmap(NULL, 4096, PROT_READ | PROT_WRITE | PROT_EXEC,
                              MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    if (code == MAP_FAILED) { perror("mmap"); exit(1); }
    const char *prefix = variadic ? "s390x-VARARGS-CALLBACK" : "s390x-CALLBACK";
    char path[128];
    snprintf(path, sizeof(path), "%s.bin", prefix);
    read_file(path, code, 4096);
    snprintf(path, sizeof(path), "%s-relocations.bin", prefix);
    unsigned char relocations[64];
    size_t length = read_file(path, relocations, sizeof(relocations));
    if (length != sizeof(values) / sizeof(values[0]) * 4) return 1;
    for (size_t i = 0; i < length / 4; i++) {
        uint32_t rel = be32(relocations + i * 4);
        if (((rel >> 24) & 15) != 15) return 1;
        unsigned char *site = code + (rel & 0xffffff) - 12;
        put_be32(site + 2, values[i] >> 32); put_be32(site + 8, values[i]);
    }
    frame_size = variadic ? 512 : 320;
    memset(captured, 0, sizeof(captured));
    uint64_t seed = UINT64_C(0x4009000000000000), restored;
    __asm__ volatile("ldgr %%f8,%0" : : "r"(seed) : "f8");
    uintptr_t result = ((callback)code)(0x11, 0x22, 0x33, 0x44, 0x55,
                                       1.25, 2.25, 3.25, 4.25,
                                       (uintptr_t)0x66, 5.25);
    __asm__ volatile("lgdr %0,%%f8" : "=r"(restored));
    uintptr_t current_context;
    memcpy(&current_context, vm + offsets[0], sizeof(current_context));
    int failed = result != 42 || restored != seed || cell_at(160) != 0x55 ||
                 cell_at(296) != (uintptr_t)original_context ||
                 current_context != (uintptr_t)original_context;
    if (variadic) {
        for (size_t i = 0; i < 5; i++) failed |= cell_at(336 + i * 8) != (i + 1) * 0x11;
        for (size_t i = 0; i < 4; i++) {
            double value; memcpy(&value, captured + 448 + i * 8, sizeof(value));
            failed |= value != (double)i + 1.25;
        }
        uintptr_t extra; double extra_fp;
        memcpy(&extra, overflow, sizeof(extra));
        memcpy(&extra_fp, overflow + 8, sizeof(extra_fp));
        failed |= cell_at(480) != 0 || cell_at(488) != 0 ||
                  cell_at(496) != saved_sp + 672 || cell_at(504) != saved_sp + 320 ||
                  extra != 0x66 || extra_fp != 5.25;
    }
    munmap(code, 4096);
    printf("%s callback snapshot/restore: %s\n", variadic ? "variadic" : "ordinary",
           failed ? "FAIL" : "PASS");
    return failed;
}
int main(void) {
    if (read_file("s390x-CALLBACK-offsets.bin", offsets, sizeof(offsets)) != sizeof(offsets)) return 1;
    return probe(0) | probe(1);
}
