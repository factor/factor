#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <sys/utsname.h>
int main(void) {
 struct utsname u; uname(&u);
 volatile uint64_t a=123456789,b=987654321;
 volatile double x=1.25,y=2.5;
 unsigned n=1; const char *e=*(unsigned char*)&n?"little":"big";
 FILE *f=fopen("/tmp/factor-infrastructure-probe","w+");char buf[32]={0};
 if(!f)return 1;
 fputs("integer-fp-file-io",f);rewind(f);fgets(buf,sizeof buf,f);fclose(f);
 if(a+b!=1111111110ULL || x*y!=3.125 || strcmp(buf,"integer-fp-file-io"))return 2;
 printf("Infrastructure C probe PASS: machine=%s pointer_bits=%zu endian=%s integer=PASS fp=PASS file_io=PASS\n",u.machine,sizeof(void*)*8,e);
 puts("This is not a Factor VM/compiler test.");return 0;
}
