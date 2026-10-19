#include <stdint.h>
#include <stdio.h>
#include <fenv.h>
extern intptr_t *run_template(intptr_t *, void (*)(void), void *);
extern void jit_swap(void),jit_add(void),jit_mul(void),jit_divmod(void);
extern void jit_checked_add(void),jit_checked_sub(void),jit_checked_mul(void);
extern void run_fpu(void (*)(void)),jit_fpu_save_restore(void);
int main(void) {
 intptr_t context[5]={0};
 void *vm[2]={context,context};
 intptr_t s[2]={48,112};
 if(run_template(s,jit_swap,vm)!=s+1 || s[0]!=112 || s[1]!=48)return 1;
 s[0]=48;s[1]=112;
 if(run_template(s,jit_add,vm)!=s || s[0]!=160)return 2;
 s[0]=-48;s[1]=112;
 if(run_template(s,jit_mul,vm)!=s || s[0]!=-336)return 3;
 s[0]=112;s[1]=-48;
 if(run_template(s,jit_divmod,vm)!=s+1 || s[0]!=-32 || s[1]!=16)return 4;
 s[0]=48;s[1]=112;
 if(run_template(s,jit_checked_add,vm)!=s || s[0]!=160)return 5;
 s[0]=48;s[1]=112;
 if(run_template(s,jit_checked_sub,vm)!=s || s[0]!=-64)return 6;
 s[0]=-48;s[1]=112;
 if(run_template(s,jit_checked_mul,vm)!=s || s[0]!=-336)return 7;
 s[0]=0;s[1]=0;
 if(run_template(s,jit_checked_mul,vm)!=s || s[0]!=0)return 8;
 if(fesetround(FE_DOWNWARD))return 9;
 run_fpu(jit_fpu_save_restore);
 if(fegetround()!=FE_DOWNWARD)return 10;
 if(fesetround(FE_TONEAREST))return 11;
 puts("Factor-generated SPARC shuffle/checked arithmetic/divmod/FPU templates passed");
}
