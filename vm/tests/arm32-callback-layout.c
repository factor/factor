#include <stdint.h>
#include <stdio.h>
#include <string.h>
extern int callback_layout(int,int,int,int,int);
extern int callback_varargs_layout(int,int,int,int,int);
int main(void) {
 uint64_t in[8]={1,2,3,4,5,6,7,8},out[8];
 __asm__ volatile("vldmia %0,{d8-d15}"::"r"(in):"d8","d9","d10","d11","d12","d13","d14","d15");
 int regular=callback_layout(17,18,19,20,42);
 __asm__ volatile("vstmia %0,{d8-d15}"::"r"(out):"memory");
 if(regular!=42 || memcmp(in,out,sizeof in)) return 1;
 int varargs=callback_varargs_layout(17,18,19,20,42);
 __asm__ volatile("vstmia %0,{d8-d15}"::"r"(out):"memory");
 if(varargs!=59 || memcmp(in,out,sizeof in)) return 2;
 puts("ARM32 callback save area112, native stack argument, varargs GP bank and d8-d15 preservation pass");
 return 0;
}
