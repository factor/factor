/* Executes bytes emitted by cpu.architecture MIPS optimizer methods. */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <sys/mman.h>
#include <unistd.h>

extern void trampoline(void), trampoline2(void);
struct gate_context { uintptr_t *frame; };
static struct gate_context *active_context;
static volatile intptr_t native_global = 7;
static intptr_t native_int12(intptr_t a, intptr_t b, intptr_t c, intptr_t d,
                            intptr_t e, intptr_t f, intptr_t g, intptr_t h,
                            intptr_t i, intptr_t j, intptr_t k, intptr_t l) {
    if (!active_context->frame || !active_context->frame[0] ||
        !active_context->frame[1]) abort();
    return a+b+c+d+e+f+g+h+i+j+k+l+native_global;
}
static double native_mixed(int a, double b, int c, double d) {
    if (!active_context->frame || !active_context->frame[0] ||
        !active_context->frame[1]) abort();
    return a+b+c+d+native_global;
}
static double native_leading(double a, double b, int c) {
    if (!active_context->frame || !active_context->frame[0] ||
        !active_context->frame[1]) abort();
    return a+b+c+native_global;
}
static intptr_t bridge_call(void *p) {
    struct gate_context context = {0};
    active_context = &context;
    register uintptr_t saved_ctx __asm__("$19") = (uintptr_t)&context;
    register uintptr_t gate __asm__("$21") = (uintptr_t)trampoline;
    register uintptr_t stack_gate __asm__("$22") = (uintptr_t)trampoline2;
    __asm__ volatile("" : : "r"(saved_ctx), "r"(gate), "r"(stack_gate));
    intptr_t result = ((intptr_t(*)(void))p)();
    __asm__ volatile("" : "+r"(saved_ctx), "+r"(gate), "+r"(stack_gate));
    return result;
}
static double bridge_call_double(void *p) {
    struct gate_context context = {0};
    active_context = &context;
    register uintptr_t saved_ctx __asm__("$19") = (uintptr_t)&context;
    register uintptr_t gate __asm__("$21") = (uintptr_t)trampoline;
    register uintptr_t stack_gate __asm__("$22") = (uintptr_t)trampoline2;
    __asm__ volatile("" : : "r"(saved_ctx), "r"(gate), "r"(stack_gate));
    double result = ((double(*)(void))p)();
    __asm__ volatile("" : "+r"(saved_ctx), "+r"(gate), "+r"(stack_gate));
    return result;
}
static uintptr_t allocation_call(void *p, uintptr_t base, uintptr_t displacement,
                                 uintptr_t *nursery) {
    uintptr_t vm[10] = {0};
    vm[2] = (uintptr_t)nursery;
    vm[4] = (uintptr_t)(nursery + 16);
    register uintptr_t vm_reg __asm__("$18") = (uintptr_t)vm;
    __asm__ volatile("" : : "r"(vm_reg));
    uintptr_t result = ((uintptr_t(*)(uintptr_t,uintptr_t))p)(base, displacement);
    __asm__ volatile("" : "+r"(vm_reg));
    return result;
}
static intptr_t mock_begin_callback(void *vm, uintptr_t quot) {
    (void)vm; (void)quot;
    if (!active_context->frame || !active_context->frame[0] ||
        !active_context->frame[1]) abort();
    return 0;
}
static void mock_end_callback(void *vm) { (void)vm; }
static uintptr_t callback_probe(void *p, int stack_only) {
    uintptr_t native_frame[40] __attribute__((aligned(16))) = {0};
    uintptr_t context[8] = {0};
    context[4] = (uintptr_t)native_frame;
#if __SIZEOF_POINTER__ == 4
    *(uintptr_t *)((char *)native_frame + 112 + 16) = 0x12345678;
    uintptr_t stack_base = (uintptr_t)native_frame + 112;
#else
    *(uintptr_t *)((char *)native_frame + 224) = 0x12345678;
    uintptr_t stack_base = (uintptr_t)native_frame + 160;
#endif
    active_context = (struct gate_context *)context;
    register uintptr_t saved_ctx __asm__("$19") = (uintptr_t)context;
    register uintptr_t gate __asm__("$21") = (uintptr_t)trampoline;
    register uintptr_t vm_reg __asm__("$18") = 0;
    __asm__ volatile("" : : "r"(saved_ctx), "r"(gate), "r"(vm_reg));
    uintptr_t result = ((uintptr_t(*)(void))p)();
    __asm__ volatile("" : "+r"(saved_ctx), "+r"(gate), "+r"(vm_reg));
    return stack_only ? result - stack_base : result;
}
static void patch(void *p, unsigned offset, uintptr_t address) {
    uint32_t *insns = (uint32_t *)((char *)p + offset);
#if __SIZEOF_POINTER__ == 4
    insns -= 2;
    insns[0] = (insns[0] & ~0xffffu) | ((address >> 16) & 0xffff);
    insns[1] = (insns[1] & ~0xffffu) | (address & 0xffff);
#else
    insns -= 7;
    for (unsigned i = 0; i < 4; ++i)
        insns[2 * i] = (insns[2 * i] & ~0xffffu) |
            ((address >> (48 - 16 * i)) & 0xffff);
#endif
}

static void *load(const char *prefix, const char *name) {
    char path[512];
    snprintf(path, sizeof(path), "%s-%s.bin", prefix, name);
    FILE *f = fopen(path, "rb");
    if (!f) { perror(path); exit(2); }
    void *p = mmap(NULL, 4096, PROT_READ | PROT_WRITE | PROT_EXEC,
                   MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    if (p == MAP_FAILED) { perror("mmap"); exit(2); }
    size_t size = fread(p, 1, 4096, f); fclose(f);
    snprintf(path, sizeof(path), "%s-%s.labels", prefix, name);
    f = fopen(path, "r");
    if (!f) { perror(path); exit(2); }
    unsigned offset, target;
    while (fscanf(f, "%u %u", &offset, &target) == 2) {
        patch(p, offset, (uintptr_t)p + target);
    }
    fclose(f);
    snprintf(path, sizeof(path), "%s-%s.relocs", prefix, name);
    f = fopen(path, "rb");
    if (!f) { perror(path); exit(2); }
    unsigned char relocation[4];
    unsigned relocation_index = 0;
    while (fread(relocation, 1, 4, f) == 4) {
        uint32_t record = relocation[0] | (relocation[1] << 8) |
            (relocation[2] << 16) | ((uint32_t)relocation[3] << 24);
        if (((record >> 24) & 15) != 14 || (record >> 28) != 0) abort();
        uintptr_t target = strcmp(name, "native-int12") == 0 ? (uintptr_t)native_int12 :
            strcmp(name, "native-mixed") == 0 ? (uintptr_t)native_mixed :
            strcmp(name, "native-leading") == 0 ? (uintptr_t)native_leading :
            strcmp(name, "callback-io") == 0 ? (relocation_index == 0 ?
                (uintptr_t)mock_begin_callback : (uintptr_t)mock_end_callback) : 0;
        ++relocation_index;
        if (!target) abort();
        patch(p, record & 0xffffff, target);
    }
    fclose(f);
    __builtin___clear_cache(p, (char *)p + size);
    return p;
}
#define CHECK(expr) do { if (!(expr)) { fprintf(stderr, "FAIL:%d:%s\n", __LINE__, #expr); return 1; } } while (0)
int main(int argc, char **argv) {
    if (argc != 2) return 2;
    const char *prefix = argv[1];
    typedef intptr_t (*binary)(intptr_t, intptr_t);
    typedef intptr_t (*unary)(intptr_t);
    typedef intptr_t (*memory)(void *);
    typedef double (*float_binary)(double, double);
    typedef intptr_t (*float_compare)(double, double);
    binary add = load(prefix, "add"), mul = load(prefix, "mul");
    binary min = load(prefix, "min-alias"), max = load(prefix, "max-alias");
    binary shift = load(prefix, "shift"), frame = load(prefix, "frame");
    unary neg = load(prefix, "neg"), large = load(prefix, "large-offset");
    for (intptr_t a = -100; a <= 100; a += 7)
        for (intptr_t b = -100; b <= 100; b += 11) {
            CHECK(add(a,b) == a+b); CHECK(mul(a,b) == a*b);
            CHECK(min(a,b) == (a < b ? a : b));
            CHECK(max(a,b) == (a > b ? a : b));
            CHECK(frame(a,b) == a+b);
        }
    CHECK(((unary)load(prefix, "negative-mask"))(0x7ff) == 0x700);
    CHECK(neg(123) == -123); CHECK(large(-123) == 69877);
    CHECK(shift(-256, 3) == -32);
    uint8_t byte = 0xff; uint32_t word = 0xfedcba98;
    CHECK(((memory)load(prefix, "unsigned-byte"))(&byte) == 255);
    CHECK(((memory)load(prefix, "signed-byte"))(&byte) == -1);
    CHECK((uintptr_t)((memory)load(prefix, "unsigned-word"))(&word) == word);
    CHECK(((float_binary)load(prefix, "float-add"))(1.25, -0.5) == 0.75);
    CHECK(((double(*)(intptr_t))load(prefix, "integer-float"))(-1234567) == -1234567.0);
    CHECK(((intptr_t(*)(double))load(prefix, "float-integer"))(-123.75) == -123);
    float_compare less = load(prefix, "float-less"), neq = load(prefix, "float-neq");
    float_compare unordered = load(prefix, "float-unordered");
    CHECK(less(1.0, 2.0) == 1); CHECK(less(2.0, 1.0) == 0);
    CHECK(less(NAN, 1.0) == 0); CHECK(neq(NAN, 1.0) == 0);
    CHECK(neq(1.0, 2.0) == 1); CHECK(neq(2.0, 2.0) == 0);
    CHECK(unordered(NAN, 1.0) == 1); CHECK(unordered(1.0, 2.0) == 0);
    unsigned char unaligned[32];
    uintptr_t cell = (uintptr_t)0xfedcba9876543210ull;
    uint16_t half = 0xfedc;
    double double_value = -1234.125;
    float float_value = -12.25f;
    memory read_half = load(prefix, "unaligned-half");
    memory read_word_alias = load(prefix, "unaligned-word-alias");
    memory read_cell = load(prefix, "unaligned-cell");
    void (*write_cell)(void*,uintptr_t) = load(prefix, "unaligned-cell-store");
    double (*read_double)(void*) = load(prefix, "unaligned-double");
    void (*write_double)(double,void*) = load(prefix, "unaligned-double-store");
    double (*read_float)(void*) = load(prefix, "unaligned-float");
    void (*write_float)(float,void*) = load(prefix, "unaligned-float-store");
    for (unsigned i = 1; i < 8; ++i) {
        memcpy(unaligned+i, &half, sizeof(half));
        CHECK((uint16_t)read_half(unaligned+i) == half);
        memcpy(unaligned+i, &word, sizeof(word));
        CHECK((uintptr_t)read_word_alias(unaligned+i) == word);
        memcpy(unaligned+i, &cell, sizeof(cell));
        CHECK((uintptr_t)read_cell(unaligned+i) == cell);
        memset(unaligned, 0xa5, sizeof(unaligned));
        write_cell(unaligned+i, cell);
        uintptr_t stored_cell; memcpy(&stored_cell, unaligned+i, sizeof(cell));
        CHECK(stored_cell == cell && unaligned[i-1] == 0xa5 &&
              unaligned[i+sizeof(cell)] == 0xa5);
        memcpy(unaligned+i, &double_value, sizeof(double_value));
        CHECK(read_double(unaligned+i) == double_value);
        memset(unaligned, 0xa5, sizeof(unaligned));
        write_double(double_value, unaligned+i);
        double stored_double; memcpy(&stored_double, unaligned+i, sizeof(stored_double));
        CHECK(stored_double == double_value && unaligned[i-1] == 0xa5 &&
              unaligned[i+sizeof(double)] == 0xa5);
        memcpy(unaligned+i, &float_value, sizeof(float_value));
        CHECK(read_float(unaligned+i) == float_value);
        memset(unaligned, 0xa5, sizeof(unaligned));
        write_float(float_value, unaligned+i);
        float stored_float; memcpy(&stored_float, unaligned+i, sizeof(stored_float));
        CHECK(stored_float == float_value && unaligned[i-1] == 0xa5 &&
              unaligned[i+sizeof(float)] == 0xa5);
    }
    uintptr_t alien[5] __attribute__((aligned(16))) = {0,1,1,0,0x12345678};
    unsigned char bytes[32] __attribute__((aligned(16))) = {0};
    unary unbox = load(prefix, "unbox-alias");
    CHECK(unbox(1) == 0);
    CHECK((uintptr_t)unbox((uintptr_t)alien + 6) == 0x12345678);
    CHECK((uintptr_t)unbox((uintptr_t)bytes + 9) == (uintptr_t)bytes + 16);
    uintptr_t nursery[16] __attribute__((aligned(16)));
    void *box = load(prefix, "box-alias"), *displaced = load(prefix, "displaced-alias");
    CHECK(allocation_call(box, 0, 0, nursery) == 1);
    CHECK(allocation_call(box, 0x12345678, 0, nursery) == (uintptr_t)nursery + 6);
    CHECK(nursery[1] == 1 && nursery[2] == 1 &&
          nursery[3] == 0x12345678 && nursery[4] == 0x12345678);
    CHECK(allocation_call(displaced, 1, 0x123, nursery) == (uintptr_t)nursery + 6);
    CHECK(nursery[1] == 1 && nursery[2] == 1 && nursery[3] == 0x123 && nursery[4] == 0x123);
    CHECK(allocation_call(displaced, (uintptr_t)bytes + 9, 7, nursery) == (uintptr_t)nursery + 6);
    CHECK(nursery[1] == (uintptr_t)bytes + 9 && nursery[3] == 7 &&
          nursery[4] == (uintptr_t)bytes + 23);
    alien[1] = (uintptr_t)bytes + 9; alien[2] = 1; alien[3] = 5;
    alien[4] = (uintptr_t)bytes + 21;
    CHECK(allocation_call(displaced, (uintptr_t)alien + 6, 7, nursery) == (uintptr_t)nursery + 6);
    CHECK(nursery[1] == (uintptr_t)bytes + 9 && nursery[2] == 1 &&
          nursery[3] == 12 && nursery[4] == (uintptr_t)bytes + 28);
    CHECK(allocation_call(displaced, (uintptr_t)alien + 6, 0, nursery) == (uintptr_t)alien + 6);
    CHECK(callback_probe(load(prefix, "callback-stack"), 1) == 0);
    CHECK(callback_probe(load(prefix, "callback-io"), 0) == 0x12345678);
    CHECK(bridge_call(load(prefix, "native-int12")) == 85);
    CHECK(bridge_call_double(load(prefix, "native-mixed")) == 18.75);
    CHECK(bridge_call_double(load(prefix, "native-leading")) == 13.75);
    puts("PASS MIPS optimizer arithmetic, aliases, memory, frames, FP, NaN branches and native PIC bridges");
    return 0;
}
