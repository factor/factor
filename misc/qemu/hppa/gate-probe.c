#include <stdint.h>
#include <stdio.h>
struct ctx {uintptr_t factor_sp;};
extern unsigned hppa_gate_probe(unsigned,unsigned(*)(unsigned),struct ctx*,uintptr_t);
extern unsigned hppa_gate_probe2(unsigned,unsigned(*)(unsigned),struct ctx*,uintptr_t);
static volatile uintptr_t native_sp;
__attribute__((noinline)) static unsigned nested(unsigned v) { volatile unsigned frame[32]; frame[0]=v; __asm__ volatile(""::"r"(frame):"memory"); __asm__ volatile("copy %%r30,%0":"=r"(native_sp)); return frame[0]+1; }
__attribute__((noinline)) static unsigned native(unsigned v) { return nested(v)+1; }
int main(void) {
 uintptr_t stack[128],before,after; struct ctx ctx={0};
 uintptr_t factor_sp=(uintptr_t)&stack[120];
 __asm__ volatile("copy %%r30,%0":"=r"(before));
 unsigned result=hppa_gate_probe(40,native,&ctx,factor_sp);
 __asm__ volatile("copy %%r30,%0":"=r"(after));
 printf("native-gate=%u factor-sp-saved=%d native-stack-up=%d native-stack-restored=%d\n",result,ctx.factor_sp==factor_sp-16,native_sp>before,before==after);
 unsigned result2=hppa_gate_probe2(40,native,&ctx,factor_sp);
 printf("native-gate2=%u linked-frame=%d saved-return=%d\n",result2,*(uintptr_t*)(factor_sp-16)==factor_sp,*(uintptr_t*)(factor_sp-12)!=0);
 return !(result2==42 && *(uintptr_t*)(factor_sp-16)==factor_sp && result==42 && ctx.factor_sp==factor_sp-16 && native_sp>before && before==after);
}
