/* Execute the generated context switch with an invalid saved return marker.
 * Build with s390x_context_upgrade.c to also execute the scoped repair. */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/resource.h>
#include <sys/wait.h>
#include <unistd.h>
#include <signal.h>
struct environment { uintptr_t code,vm,ctx,ds,rs,sp,fp,out[6]; };
extern void run_context(struct environment *);
extern size_t patch_context_code(void *,size_t);
__asm__(".text\n.global run_context\n.type run_context,@function\n"
"run_context:\nstmg %r6,%r15,48(%r15)\naghi %r15,-192\n"
"lgr %r10,%r15\nlgr %r11,%r2\n"
"lg %r1,0(%r11)\nlg %r9,8(%r11)\nlg %r8,16(%r11)\n"
"lg %r6,24(%r11)\nlg %r7,32(%r11)\nlg %r12,48(%r11)\nlg %r15,40(%r11)\n"
"basr %r14,%r1\n"
"stg %r15,56(%r11)\nstg %r12,64(%r11)\nstg %r6,72(%r11)\n"
"stg %r7,80(%r11)\nstg %r8,88(%r11)\nstg %r14,96(%r11)\n"
"lgr %r15,%r10\naghi %r15,192\nlmg %r6,%r15,48(%r15)\nbr %r14\n"
".size run_context,.-run_context\n");
static size_t read_file(const char *name,void *p,size_t cap) {
 FILE *f=fopen(name,"rb");if(!f){perror(name);exit(1);}size_t n=fread(p,1,cap,f);fclose(f);return n;
}
static void cell(void *p,size_t off,uintptr_t n){memcpy((char*)p+off,&n,8);}
int main(void) {
 unsigned char offsets[6],extra[2];
 if(read_file("s390x-CALLBACK-offsets.bin",offsets,6)!=6||read_file("s390x-CONTEXT-offsets.bin",extra,2)!=2)return 1;
 unsigned char *code=mmap(0,4096,7,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);if(code==MAP_FAILED)return 1;
 size_t n=read_file("s390x-(set-context).bin",code,4094);code[n]=7;code[n+1]=0xfe;
 _Alignas(16) uintptr_t old_stack[64]={0},new_stack[64]={0},old_ds[32]={0},new_ds[32]={0},rs[32]={0};
 unsigned char vm[128]={0},old_ctx[128]={0},new_ctx[128]={0},alien[64]={0};
 cell(alien,extra[1]+6,(uintptr_t)new_ctx);old_ds[2]=0x12345678;old_ds[3]=(uintptr_t)alien+6;
 cell(new_ctx,extra[0],(uintptr_t)new_stack);cell(new_ctx,offsets[4],(uintptr_t)new_ds);
 cell(new_ctx,offsets[5],(uintptr_t)rs);new_stack[0]=(uintptr_t)(new_stack+8);new_stack[1]=1;
 struct environment e={(uintptr_t)code,(uintptr_t)vm,(uintptr_t)old_ctx,(uintptr_t)(old_ds+3),(uintptr_t)rs,(uintptr_t)(old_stack+16),(uintptr_t)(old_stack+24),{0}};
 run_context(&e);
 uintptr_t ctx;memcpy(&ctx,vm+offsets[0],8);
 int fail=e.out[0]!=(uintptr_t)(new_stack+2)||e.out[1]!=new_stack[0]||e.out[2]!=(uintptr_t)(new_ds+1)||e.out[3]!=(uintptr_t)rs||e.out[4]!=(uintptr_t)new_ctx||ctx!=(uintptr_t)new_ctx||new_ds[1]!=0x12345678;
 size_t site=0;
 const unsigned char nops[]={7,0,7,0,7,0},old_load[]={0xe3,0xe0,0xf0,8,0,4};
 for(size_t i=0;i+6<=n;i++)if(!memcmp(code+i,nops,6)){site=i;break;}
 if(!site)return 1;
 pid_t child=fork();if(child<0)return 1;
 if(!child){struct rlimit limit={0,0};setrlimit(RLIMIT_CORE,&limit);memcpy(code+site,old_load,6);run_context(&e);_exit(2);}
 int status;waitpid(child,&status,0);fail|=!WIFSIGNALED(status)||(WTERMSIG(status)!=SIGSEGV&&WTERMSIG(status)!=SIGILL);
 memcpy(code+site,old_load,6);fail|=patch_context_code(code,n)!=1;
 run_context(&e);fail|=patch_context_code(code,n)!=0;
 printf("negative control status=%d\n",status);
 printf("context switch live return/address/stacks and old-layout negative control: %s\n",fail?"FAIL":"PASS");return fail;
}
