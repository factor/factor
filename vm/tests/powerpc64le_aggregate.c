#include <stdint.h>
#include <stdio.h>
struct pair {uint64_t a,b;}; struct hfa {float a[8];};
__attribute__((noinline)) struct pair abi_pair(void){return (struct pair){11,22};}
__attribute__((noinline)) struct hfa abi_hfa(void){return (struct hfa){{1,2,3,4,5,6,7,8}};}
extern void probe_pair(uint64_t*); extern void probe_hfa(float*);
int main(void){uint64_t p[2]={0};float f[8]={0};probe_pair(p);probe_hfa(f);if(p[0]!=11||p[1]!=22)return 1;for(int i=0;i<8;i++)if(f[i]!=i+1)return 2;puts("PASS ELFv2 two-GPR aggregate and eight-FPR HFA returns");return 0;}
