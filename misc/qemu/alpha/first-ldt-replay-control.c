/* Owned first-FP-load replay diagnostic. No FPCR writes or test changes. */
#include <stdint.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/wait.h>
#include <errno.h>
#include <string.h>
struct capture { uint64_t first, second; };
static uint64_t read_fpcr(void) {
 uint64_t raw;
 __asm__ volatile("excb\n\tmf_fpcr %0\n\texcb" : "=f"(raw) :: "memory");
 return raw;
}
int main(void) {
 const uint64_t a=UINT64_C(0x0123456789abcdef);
 const uint64_t b=UINT64_C(0x3ff123456789abcd);
 unsigned failures=0;
 uint64_t parent_before=read_fpcr();
 for (unsigned warm=0;warm<2;warm++) for(unsigned repeat=0;repeat<4;repeat++) {
  int channel[2];
  if(pipe(channel)) {perror("pipe");return 2;}
  pid_t pid=fork();
  if(pid<0) {perror("fork");return 2;}
  if(pid==0) {
   struct capture out={0,0};
   uint64_t input_a=a,input_b=b;
   if(warm) (void)read_fpcr();
   double scratch;
   __asm__ volatile("ldt %0,%2\n\tstt %0,%1"
     : "=&f"(scratch), "=m"(out.first) : "m"(input_a) : "memory");
   __asm__ volatile("ldt %0,%2\n\tstt %0,%1"
     : "=&f"(scratch), "=m"(out.second) : "m"(input_b) : "memory");
   close(channel[0]);
   ssize_t sent=write(channel[1],&out,sizeof(out));
   close(channel[1]);
   _exit(sent==(ssize_t)sizeof(out)?0:98);
  }
  close(channel[1]);struct capture out={0,0};size_t got=0;
  while(got<sizeof(out)) {
   ssize_t n=read(channel[0],(char*)&out+got,sizeof(out)-got);
   if(n<0 && errno==EINTR) continue;
   if(n<=0) break;
   got+=(size_t)n;
  }
  close(channel[0]);int status=0;pid_t waited;
  do {waited=waitpid(pid,&status,0);} while(waited<0 && errno==EINTR);
  int child_ok=waited==pid && WIFEXITED(status) && WEXITSTATUS(status)==0;
  int first_ok=out.first==a,second_ok=out.second==b;
  failures+=got!=sizeof(out)||!child_ok||!first_ok||!second_ok;
  printf("warm=%u repeat=%u first=%016llx expected_first=%016llx second=%016llx expected_second=%016llx first_ok=%d second_ok=%d child_ok=%d bytes=%zu\n",
   warm,repeat,(unsigned long long)out.first,(unsigned long long)a,
   (unsigned long long)out.second,(unsigned long long)b,first_ok,second_ok,child_ok,got);
 }
 uint64_t parent_after=read_fpcr();
 printf("failures=%u parent_before=%016llx parent_after=%016llx\n",failures,
  (unsigned long long)parent_before,(unsigned long long)parent_after);
 return failures?1:0;
}
