#include <sys/mman.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>
int main(int argc,char **argv) {
 unsigned char *p=mmap(0,4096,PROT_READ|PROT_WRITE|PROT_EXEC,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
 FILE *f=fopen(argv[1],"rb"); if(p==MAP_FAILED || !f)return 2;
 size_t n=fread(p,1,4096,f); fclose(f);
 if(strstr(argv[1],"pointer")){
  uint32_t *words=(void*)p;
  for(size_t i=0;i<n/4;i++){
   unsigned op2=(words[i]>>22)&7;
   if(words[i]>>30==0 && (op2==1 || op2==2)){
    unsigned mask=op2==1?0x7ffff:0x3fffff;
    words[i]=(words[i]&~mask)|(((n-12)/4-i)&mask);
   }
  }
 }
 __builtin___clear_cache((char*)p,(char*)p+n);
 long (*fn)(long,long)=(void*)p;
 if(strstr(argv[1],"large")){
  for(long value=-500;value<=500;value++)if(fn(value,0)!=value)return 7;
  printf("Factor emitted SPARC%zu large frame/integer/FP memory: 1001 cases PASS\n",sizeof(long)*8);return 0;
 }
 if(strstr(argv[1],"pointer")){
  _Alignas(16) uintptr_t object[8]={0};
  if(fn(1,0)!=0)return 4;
  if(fn((uintptr_t)object+9,0)!=(uintptr_t)object+16)return 5;
  for(long value=-500;value<=500;value++){
   object[4]=value;
   if(fn((uintptr_t)object+6,0)!=value)return 6;
  }
  printf("Factor emitted SPARC%zu aliased false/byte-array/alien pointers: 1003 cases PASS\n",sizeof(long)*8);return 0;
 }
 for(long a=-20;a<=20;a++)for(long b=-20;b<=20;b++)if(fn(a,b)!=a+b)return 3;
 printf("Factor emitted SPARC%zu SAVE/add/RESTORE/return: 1681 cases PASS\n",sizeof(long)*8);return 0;
}
