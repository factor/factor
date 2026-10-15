#define _GNU_SOURCE
#include <sys/mount.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <sys/utsname.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
int main(void) {
 mount("devtmpfs","/dev","devtmpfs",0,0);
 int console=open("/dev/console",O_RDWR); if(console>=0) {dup2(console,0);dup2(console,1);dup2(console,2);}
 setbuf(stdout,0);setbuf(stderr,0);
 mount("proc","/proc","proc",0,0);mount("sysfs","/sys","sysfs",0,0);
 struct utsname u;uname(&u);
 printf("HPPA native kernel probe: kernel=%s machine=%s pointers=%zu pid=%ld\n",u.release,u.machine,sizeof(void*),(long)getpid());
 const char* tests[]={"/abi-probe","/code-probe","/signal-probe","/gate-probe","/atomic-signal-probe","/gc-tests"};
 unsigned failures=0;
 for(unsigned i=0;i<sizeof(tests)/sizeof(tests[0]);i++) {
  pid_t child=fork(); if(child==0) {execl(tests[i],tests[i],(char*)0);_exit(127);}
  int status=0;if(child<0||waitpid(child,&status,0)!=child||!WIFEXITED(status)||WEXITSTATUS(status)!=0) failures++;
  printf("HPPA native kernel test=%s status=%d\n",tests[i],status);
 }
 printf("HPPA_NATIVE_KERNEL_PROBES_FAILURES=%u\n",failures);
 // Preserve the guest and console for inspection; never turn this result
 // into Factor compiler/io acceptance.
 for(;;) pause();
}
