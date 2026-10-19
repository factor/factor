#include <sys/mman.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
extern int sparc_compiler_enter(void (*fn)(void),void *data,void *retain,void *vm);
#ifdef __arch64__
__asm__(".register %g2,#scratch\n.register %g3,#scratch");
#endif
extern void trampoline2(void);
static int native_add(int a,int b){__asm__ volatile("mov 7,%%g2\nmov 8,%%g3\nmov 9,%%g4":::"g2","g3","g4");return a+b;}
static double native_fp(double a,double b){__asm__ volatile("mov 7,%%g2\nmov 8,%%g3\nmov 9,%%g4":::"g2","g3","g4");return a*3+b*2;}
union single_union {double value;};
static union single_union native_union(int a,int b){uint64_t bits=UINT64_C(0x4000000000000000)+a+b;union single_union result;memcpy(&result,&bits,8);return result;}
static int to_signed_4(uintptr_t value,void *vm){return (intptr_t)value/16;}
static uintptr_t from_signed_4(int value,void *vm){return (uintptr_t)((intptr_t)value*16);}
static void *native_symbol(const char *symbol){
 if(!strcmp(symbol,"sparc_probe_add"))return native_add;
 if(!strcmp(symbol,"sparc_probe_fp"))return native_fp;
 if(!strcmp(symbol,"sparc_probe_union"))return native_union;
 if(!strcmp(symbol,"to_signed_4"))return to_signed_4;
 if(!strcmp(symbol,"from_signed_4"))return from_signed_4;
 fprintf(stderr,"unsupported native probe symbol: %s\n",symbol);exit(9);
}
static long next_number(FILE *f){int c;do{c=fgetc(f);}while(c!=EOF&&!isdigit(c)&&c!='-');if(c==EOF)return -1;ungetc(c,f);long result;if(fscanf(f,"%ld",&result)!=1)abort();return result;}
int main(int argc,char **argv){
 unsigned char *code=mmap(0,65536,PROT_READ|PROT_WRITE|PROT_EXEC,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
 FILE *f=fopen(argv[1],"rb");if(code==MAP_FAILED||!f)return 2;
 size_t n=fread(code,1,65536,f);fclose(f);
 char labels[4096];snprintf(labels,sizeof labels,"%s.labels",argv[1]);f=fopen(labels,"r");if(!f)return 3;
 long cls;while((cls=next_number(f))>=0){
  long offset=next_number(f),target=next_number(f);
  if(cls!=14||offset<4||target<0)return 4;
  uint32_t *word=(void*)(code+offset-4);unsigned op2=(*word>>22)&7;
  unsigned mask=op2==1?0x7ffff:0x3fffff;
  *word=(*word&~mask)|(((target-offset+4)/4)&mask);
 }
 fclose(f);
 snprintf(labels,sizeof labels,"%s.relocs",argv[1]);f=fopen(labels,"rb");if(!f)return 6;
 snprintf(labels,sizeof labels,"%s.symbols",argv[1]);FILE *symbols=fopen(labels,"r");if(!symbols)return 10;
 unsigned char entry[4];static unsigned char safepoint;
 while(fread(entry,1,4,f)==4){
  uint32_t bits=(uint32_t)entry[0]<<24|(uint32_t)entry[1]<<16|(uint32_t)entry[2]<<8|entry[3];
  unsigned type=bits>>28;
  uint64_t address;
  if(type==15)address=(uintptr_t)&safepoint;
  else if(type==13)address=(uintptr_t)trampoline2;
  else if(type==0){
   char symbol[256];if(!fgets(symbol,sizeof symbol,symbols))return 11;
   symbol[strcspn(symbol,"\r\n")]=0;address=(uintptr_t)native_symbol(symbol);
  }else continue;
  if((bits>>24&15)!=15)return 7;
  uint32_t *words=(void*)(code+(bits&0xffffff)-(sizeof(long)==8?24:8));
  if(sizeof(long)==8){
   words[0]=(words[0]&~0x3fffff)|((address>>42)&0x3fffff);
   words[1]=(words[1]&~0x3ff)|((address>>32)&0x3ff);
   words+=3;
  }
  words[0]=(words[0]&~0x3fffff)|((address>>10)&0x3fffff);
  words[1]=(words[1]&~0x3ff)|(address&0x3ff);
 }
 fclose(symbols);fclose(f);__builtin___clear_cache((char*)code,(char*)code+n);
 void (*fn)(void)=(void*)code;
 _Alignas(16) uintptr_t data[16]={0},retain[16]={0},object[16]={0};
 _Alignas(16) unsigned char float_a[16],float_b[16],nursery[64];
 uintptr_t vm[16]={0},context[16]={0};vm[0]=(uintptr_t)context;
 int aggregate_union=strstr(argv[1],"call-native-union")!=0;
 int native_floating=strstr(argv[1],"call-native-floats")!=0;
 int floating=strstr(argv[1],"add-floats")!=0 || native_floating;
 int slot=strstr(argv[1],"get-slot")!=0,min=strstr(argv[1],"min-")!=0,mul=strstr(argv[1],"multiply-")!=0;
 for(long a=-20;a<=20;a++)for(long b=-20;b<=20;b++){
  data[0]=(uintptr_t)(a*16);data[1]=(uintptr_t)(b*16);
  uintptr_t *top=data+1;
  if(slot){object[1]=a*16;data[0]=(uintptr_t)object+9;top=data;}
  if(floating){
   *(double*)(float_a+8)=a*0.5;*(double*)(float_b+8)=b*0.25;
   data[0]=(uintptr_t)float_a+3;data[1]=(uintptr_t)float_b+3;
   vm[2]=(uintptr_t)nursery;vm[4]=(uintptr_t)(nursery+sizeof nursery);
  }
  if(aggregate_union){vm[2]=(uintptr_t)nursery;vm[4]=(uintptr_t)(nursery+sizeof nursery);}
  if(sparc_compiler_enter(fn,top,retain,vm)) {
   fprintf(stderr,"compiled word overwrote caller register window: %s\n",argv[1]);return 13;
  }uintptr_t actual_top;__asm__ volatile("mov %%g2,%0":"=r"(actual_top));
  long expected=slot?a:min?(a<b?a:b):mul?a*b:a+b;
  if(aggregate_union){
   if(actual_top!=(uintptr_t)data || data[0]!=(uintptr_t)nursery+39 ||
      ((uintptr_t*)nursery)[6]!=(uintptr_t)nursery+9 ||
      *(uint64_t*)(nursery+16)!=UINT64_C(0x4000000000000000)+a+b ||
      vm[2]!=(uintptr_t)nursery+64)return 12;
  }else if(floating){
   if(actual_top!=(uintptr_t)data || data[0]!=(uintptr_t)nursery+3 || *(double*)(nursery+8)!=(native_floating?a*1.5+b*0.5:a*0.5+b*0.25) || vm[2]!=(uintptr_t)nursery+16)return 8;
  }else if(actual_top!=(uintptr_t)data || data[0]!=(uintptr_t)(expected*16)){
   fprintf(stderr,"%s a=%ld b=%ld got=%ld expected=%ld top=%p\n",argv[1],a,b,(long)data[0]/16,expected,(void*)actual_top);return 5;
  }
 }
 printf("Factor optimizing compiler SPARC%zu %s: 1681 cases PASS\n",sizeof(long)*8,argv[1]);return 0;
}
