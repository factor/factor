USING: alien.c-types alien.syntax classes.struct ;
IN: unix.types

TYPEDEF: int clockid_t
TYPEDEF: ulonglong dev_t
TYPEDEF: ulonglong ino_t
TYPEDEF: uint mode_t
TYPEDEF: uint nlink_t
TYPEDEF: uint uid_t
TYPEDEF: uint gid_t
TYPEDEF: longlong off_t
TYPEDEF: longlong blkcnt_t
TYPEDEF: longlong ino64_t
TYPEDEF: int blksize_t
TYPEDEF: uint fflags_t
TYPEDEF: int pid_t
TYPEDEF: longlong time_t
TYPEDEF: int suseconds_t

TYPEDEF: uint[4] sigset_t

STRUCT: posix_spawn_file_actions_t
    { size uint }
    { len uint }
    { fae void* }
    ;

STRUCT: posix_spawnattr_t
    { flags short }
    { pgroup pid_t }
    { sched_priority int }
    { schedpolicy int }
    { sigdefault sigset_t }
    { sigmask sigset_t }
    ;
