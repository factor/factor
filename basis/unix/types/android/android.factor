USING: alien.c-types alien.syntax classes.struct kernel ;
IN: unix.types

TYPEDEF: int clockid_t
TYPEDEF: ulonglong dev_t
TYPEDEF: ulong ino_t
TYPEDEF: ino_t __ino_t
TYPEDEF: uint mode_t
TYPEDEF: uint nlink_t
TYPEDEF: uint uid_t
TYPEDEF: uint gid_t
TYPEDEF: longlong off_t
TYPEDEF: off_t __off_t
TYPEDEF: long blksize_t
TYPEDEF: long blkcnt_t
TYPEDEF: int pid_t
TYPEDEF: long suseconds_t
TYPEDEF: long time_t
TYPEDEF: time_t __time_t

TYPEDEF: ssize_t __SWORD_TYPE
TYPEDEF: long blkcnt64_t
TYPEDEF: ulonglong __fsblkcnt64_t
TYPEDEF: ulonglong __fsfilcnt64_t
TYPEDEF: ulong ino64_t
TYPEDEF: longlong off64_t

STRUCT: sched_param
    { sched_priority int } ;

! Bionic deliberately keeps spawn state private and returns it through a
! pointer-sized handle. The public API receives pointers to these handles.
TYPEDEF: void* posix_spawn_file_actions_t
TYPEDEF: void* posix_spawnattr_t

! Both supported Android ABIs are LP64. Their public signal set is one word.
STRUCT: sigset_t
    { val ulong[1] } ;
