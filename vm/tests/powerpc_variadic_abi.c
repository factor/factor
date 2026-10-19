#include <stdint.h>
#include <stdio.h>
struct capture { uint32_t cr; uint32_t pad; double fp; uint64_t gp; };
extern void varcapture(struct capture*, ...);
int main(void) {
 struct capture result={0}; varcapture(&result,1.5);
#if __SIZEOF_POINTER__ == 4
 if (!(result.cr & 0x02000000u) || result.fp !=1.5) return 1;
#else
 union {double f; uint64_t u;} expected={.f=1.5};
 if(result.gp!=expected.u) return 2;
#endif
 printf("PASS variadic CR=%08x FPR=%g GP=%016llx\n",result.cr,result.fp,(unsigned long long)result.gp);
 return 0;
}
