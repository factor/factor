#include <stdio.h>

#if defined(__FreeBSD__)
	#define BSD
	#define FREEBSD
	#define UNIX
#endif

#if defined(__NetBSD__)
	#define BSD
	#define NETBSD
	#define UNIX
#endif

#if (__OpenBSD__)
	#define BSD
	#define OPENBSD
	#define UNIX
#endif

#if defined(linux)
	#define LINUX
	#define UNIX
#endif

#if defined(__amd64__) || defined(__x86_64__)
	#define BIT64
#else
	#define BIT32
#endif

#if defined(UNIX)
	#include <sys/types.h>
	#include <sys/stat.h>
#endif


#define BL printf(" ");
#define QUOT printf("\"");
#define NL printf("\n");
#define LB printf("{"); BL
#define RB BL printf("}");
#define SEMI printf(";");
#define grovel(t) printf("TYPEDEF: "); printf("%d", sizeof(t)); BL printf(#t); NL
#define grovel2impl(t,n) BL BL BL BL LB QUOT printf(#t); QUOT BL QUOT printf((n)); QUOT RB
#define grovel2(t,n) grovel2impl(t,n) NL
#define grovel2end(t,n) grovel2impl(t,n) BL SEMI NL
#define header(os) printf("vvv %s vvv", (os)); NL
#define footer(os) printf("^^^ %s ^^^", (os)); NL
#define header2(os,struct) printf("vvv %s %s vvv", (os), (struct)); NL
#define footer2(os,struct) printf("^^^ %s %s ^^^", (os), (struct)); NL
#define struct(n) printf("C-STRUCT: %s\n", (n));

void openbsd_types()
{
	header2("openbsd", "types");
	grovel(dev_t);
	grovel(gid_t);
	grovel(ino_t);
	grovel(int32_t);
	grovel(int64_t);
	grovel(mode_t);
	grovel(nlink_t);
	grovel(off_t);
	grovel(struct timespec);
	grovel(uid_t);
	footer2("openbsd", "types");
}

void openbsd_stat()
{
	header2("openbsd", "stat");
	struct("stat");
	grovel2(dev_t, "st_dev");
	grovel2(ino_t, "st_ino");
	grovel2(mode_t, "st_mode");
	grovel2(nlink_t, "st_nlink");
	grovel2(uid_t, "st_uid");
	grovel2(gid_t, "st_gid");
	grovel2(dev_t, "st_rdev");
	grovel2(int32_t, "st_lspare0");
	grovel2(struct timespec, "st_atimespec");
	grovel2(struct timespec, "st_mtimespec");
	grovel2(struct timespec, "st_ctimespec");
	grovel2(off_t, "st_size");
	grovel2(int64_t, "st_blocks");
	grovel2(u_int32_t, "st_blksize");
	grovel2(u_int32_t, "st_flags");
	grovel2(u_int32_t, "st_gen");
	grovel2(int32_t, "st_lspare1");
	grovel2(struct timespec, "st_birthtimespec");
	grovel2(int64_t, "st_qspare1");
	grovel2end(int64_t, "st_qspare2");
	footer2("openbsd", "stat");
}

void unix_types()
{
	grovel(dev_t);
	grovel(gid_t);
	grovel(ino_t);
	grovel(int32_t);
	grovel(int64_t);
	grovel(mode_t);
	grovel(nlink_t);
	grovel(off_t);
	grovel(struct timespec);
	grovel(struct stat);
	grovel(time_t);
	grovel(uid_t);
}
	
int main() {
	//grovel(char);
	//grovel(int);
	//grovel(uint);
	//grovel(long);
	//grovel(ulong);
	//grovel(long long);
	//grovel(unsigned long long);
	//grovel(void*);
	//grovel(char*);

#ifdef FREEBSD
	grovel(blkcnt_t);
	grovel(blksize_t);
	grovel(fflags_t);
#endif

#ifdef OPENBSD
	openbsd_stat();
	openbsd_types();
#endif

#ifdef UNIX
	unix_types();
#endif

	return 0;
}
