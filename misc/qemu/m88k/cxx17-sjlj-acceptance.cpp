// Runtime acceptance for the GNU m88k SjLj ABI; no standard library headers.
static volatile int destroyed;
namespace factor { struct must_start_gc_again {}; }
__attribute__((noinline)) static void restart_gc() { throw factor::must_start_gc_again(); }
struct guard { int value; ~guard() { destroyed += value; } };
extern "C" __attribute__((noreturn)) void m88k_sjlj_poison_throw(int value);
extern "C" __attribute__((noinline,noreturn)) void m88k_sjlj_throw_helper(int value) { throw value; }
__attribute__((noinline)) static void fail(int value) { m88k_sjlj_poison_throw(value); }
__attribute__((noinline)) static int cleanup(int value) {
    guard g = { 3 };
    fail(value);
    return 0;
}
__attribute__((noinline)) static int nested(int value) {
    try { guard g = { 5 }; cleanup(value); }
    catch (int caught) { if (caught != value) return -1; throw; }
    return -2;
}
extern "C" int m88k_sjlj_acceptance(int input) {
    int errors = 0;
    destroyed = 0;
    volatile int preserve = input + 17;
    try { nested(input); errors |= 1; }
    catch (double) { errors |= 2; }
    catch (int value) { if (value != input || preserve != input + 17) errors |= 4; }
    catch (...) { errors |= 8; }
    if (destroyed != 8) errors |= 16;
    try { if (input & 1) fail(input + 1); else fail(input + 2); }
    catch (int value) { if (value != input + ((input & 1) ? 1 : 2)) errors |= 32; }
    try { restart_gc(); errors |= 64; }
    catch (const factor::must_start_gc_again&) {}
    catch (...) { errors |= 128; }
    return errors;
}
