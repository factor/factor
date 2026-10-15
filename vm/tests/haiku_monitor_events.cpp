// NATIVE HAIKU ONLY. Compile with build/os-haiku-monitors.o -lbe -lroot.
// Must pass alongside the entire original io.monitors vocabulary tests.
#include <cassert>
#include <cerrno>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fcntl.h>
#include <poll.h>
#include <set>
#include <string>
#include <unistd.h>
#include <vector>
struct event_record {int32_t action;char name[256];};
static_assert(sizeof(event_record)==260,"exported record ABI");
extern "C" void* factor_haiku_monitor_open(const char*);
extern "C" int factor_haiku_monitor_fd(void*);
extern "C" int factor_haiku_monitor_take_fd(void*);
extern "C" int factor_haiku_monitor_next(void*,event_record*);
extern "C" void factor_haiku_monitor_close(void*);
static event_record next(void* h) {
 event_record e={};int fd=factor_haiku_monitor_fd(h);
 for(int i=0;i<50;i++) {
  int n=factor_haiku_monitor_next(h,&e);assert(n>=0);if(n)return e;
  pollfd p={fd,POLLIN,0};int r=poll(&p,1,100);assert(r>=0);
  if(r){char wake;assert(read(fd,&wake,1)==1);}
 }
 assert(!"native event deadline exceeded");return e;
}
static void touch(const std::string& path) {int fd=open(path.c_str(),O_CREAT|O_WRONLY,0600);assert(fd>=0);assert(write(fd,"x",1)==1);assert(close(fd)==0);}
int main(){
 std::string pattern=std::string(getenv("TMPDIR") ? getenv("TMPDIR") : "/tmp") + "/factor-node-monitor-XXXXXX"; std::vector<char> storage(pattern.begin(),pattern.end()); storage.push_back(0); char* dir=storage.data();assert(mkdtemp(dir));std::string root=dir;
 touch(root+"/existing");assert(link((root+"/existing").c_str(),(root+"/linked").c_str())==0);
 void* pending=factor_haiku_monitor_open(dir);assert(pending);
 int pending_fd=factor_haiku_monitor_fd(pending);factor_haiku_monitor_close(pending);
 assert(fcntl(pending_fd,F_GETFD)<0&&errno==EBADF);
 void* h=factor_haiku_monitor_open(dir);assert(h);int fd=factor_haiku_monitor_take_fd(h);assert(fd>=0);
 assert(fcntl(fd,F_GETFL)&O_NONBLOCK);assert(fcntl(fd,F_GETFD)&FD_CLOEXEC);
 // Create/unlink before consuming any notifications: snapshots could lose
 // every one of these transient files, whereas actual events must retain them.
 for(int i=0;i<40;i++){std::string p=root+"/transient"+std::to_string(i);touch(p);assert(unlink(p.c_str())==0);}
 std::set<std::string> added,removed;
 for(int i=0;i<400&&(added.size()<40||removed.size()<40);i++){
  auto e=next(h);std::string name=e.name;if(name.find("transient")==0){if(e.action==1)added.insert(name);if(e.action==2)removed.insert(name);}
 }
 assert(added.size()==40&&removed==added);
 touch(root+"/existing");std::set<std::string> modified;
 for(int i=0;i<400&&modified.size()<2;i++){auto e=next(h);if(e.action==3&&(strcmp(e.name,"existing")==0||strcmp(e.name,"linked")==0))modified.insert(e.name);}
 assert(modified.size()==2);
 assert(rename((root+"/existing").c_str(),(root+"/renamed").c_str())==0);bool old=false,fresh=false;
 for(int i=0;i<400&&(!old||!fresh);i++){auto e=next(h);old|=e.action==4&&strcmp(e.name,"existing")==0;fresh|=e.action==5&&strcmp(e.name,"renamed")==0;}
 assert(old&&fresh);
 factor_haiku_monitor_close(h);char b;while(read(fd,&b,1)==1){}assert(read(fd,&b,1)==0);assert(close(fd)==0);
 assert(unlink((root+"/renamed").c_str())==0);assert(unlink((root+"/linked").c_str())==0);assert(rmdir(dir)==0);
 errno=0;assert(!factor_haiku_monitor_open("/missing/factor-native-monitor"));assert(errno!=0);
 puts("NATIVE HAIKU: transient40/hardlink-modifications/rename/FD-lifetime/missing-path PASS");
}
