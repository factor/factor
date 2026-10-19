#include <cstdio>
#include <cstdint>
#include <cstring>
#include <cstddef>
#include <dlfcn.h>
#include <sys/utsname.h>
#include <signal.h>
using callback = long (*)(long,long,long,long,long,long,long,long);
extern "C" long native_sum8(long a,long b,long c,long d,long e,long f,long g,long h) { return a+b+c+d+e+f+g+h; }
extern "C" long native_callback8(callback fn) { return fn(1,2,3,4,5,6,7,8); }
extern "C" double native_fp(double a,float b,long c,double d,float e,long f,double g,double h) { return a+b+c+d+e+f+g+h; }
#ifndef ABI_LIBRARY
static volatile sig_atomic_t signal_seen;
static unsigned long signal_pc, signal_sp;
static void signal_probe(int number, siginfo_t*, void* context) {
 auto* sc = static_cast<struct sigcontext*>(context);
 signal_seen = number;
 signal_pc = static_cast<unsigned long>(static_cast<unsigned int>(sc->sc_frame.srr0));
 signal_sp = static_cast<unsigned long>(sc->sc_frame.fixreg[1]);
}
int main() {
 unsigned x=0x01020304; utsname u; if(uname(&u)) return 1;
 std::printf("system=%s release=%s machine=%s pointer=%zu long=%zu size_t=%zu endian=%s sigcontext=%zu\n",u.sysname,u.release,u.machine,sizeof(void*),sizeof(long),sizeof(size_t),*(unsigned char*)&x==1?"big":"little",sizeof(struct sigcontext));
 struct sigaction sa{}; sa.sa_sigaction=signal_probe; sa.sa_flags=SA_SIGINFO; sigemptyset(&sa.sa_mask);
 if(sigaction(SIGUSR1,&sa,nullptr)||raise(SIGUSR1))return 5;
 std::printf("signal=%d pc=%lx sp=%lx pc_offset=%zu sp_offset=%zu gpr_width=%zu\n",(int)signal_seen,signal_pc,signal_sp,offsetof(struct sigcontext,sc_frame)+offsetof(struct trapframe,srr0),offsetof(struct sigcontext,sc_frame)+offsetof(struct trapframe,fixreg)+sizeof(((struct trapframe*)nullptr)->fixreg[0]),sizeof(((struct trapframe*)nullptr)->fixreg[0]));
 if(signal_seen!=SIGUSR1||!signal_pc||!signal_sp)return 6;
 void* lib=dlopen("./libabi-probe.so",RTLD_NOW); if(!lib){std::printf("dlopen=%s\n",dlerror());return 2;}
 auto sum=(callback)dlsym(lib,"native_sum8"); auto cb=(long(*)(callback))dlsym(lib,"native_callback8"); auto fp=(double(*)(double,float,long,double,float,long,double,double))dlsym(lib,"native_fp");
 if(!sum||!cb||!fp)return 3;
 long s=sum(1,2,3,4,5,6,7,8), c=cb(native_sum8); double d=fp(1.25,2.5f,3,4.25,5.5f,6,7.25,8.5);
 std::printf("sum8=%ld callback8=%ld mixed_fp=%.2f C++17=%ld\n",s,c,d,(long)__cplusplus); dlclose(lib);return s==36&&c==36&&d==38.25&&sizeof(void*)==4&&*(unsigned char*)&x==1?0:4;
}
#endif
