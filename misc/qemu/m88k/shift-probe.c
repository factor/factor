#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include "shift-generated.h"
extern void m88k_cache_sync(void*,unsigned);
extern void shift_call(unsigned*,void*);
int main(void) {
 int values[]={0,1,-1,134217727,-134217728,12345,-98765};
 int shifts[]={0,1,-1,2,-2,5,-5,27,-27,28,-28,31,-31,32,-32,33,-33,67,-67};
 void* p=mmap(0,4096,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANON,-1,0);
 unsigned cells[2],expected;int i,j,n,count=0;
 assert(p!=MAP_FAILED);memcpy(p,code,sizeof(code));m88k_cache_sync(p,sizeof(code));
 assert(mprotect(p,4096,PROT_READ|PROT_EXEC)==0);
 for(i=0;i<7;i++)for(j=0;j<19;j++) {
  n=shifts[j];cells[0]=(unsigned)values[i]<<4;cells[1]=(unsigned)n<<4;
  expected=n>=0?cells[0]<<(n&31):((int)cells[0]>>((-n)&31))&~15U;
  shift_call(cells,p);
  if(cells[0]!=expected)printf("FAIL x=%d n=%d got=%08x expected=%08x\n",values[i],n,cells[0],expected);
  assert(cells[0]==expected);assert((cells[0]&15)==0);count++;
 }
 printf("m88k fast fixnum shift PASS %d vectors\n",count);return 0;
}
