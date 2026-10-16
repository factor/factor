USING: alien.c-types alien.syntax classes.struct ;
IN: unix.types

TYPEDEF: int clockid_t
TYPEDEF: ulong dev_t
TYPEDEF: ulong ino_t
TYPEDEF: uint mode_t
TYPEDEF: uint nlink_t
TYPEDEF: uint uid_t
TYPEDEF: uint gid_t
TYPEDEF: long off_t
TYPEDEF: long blkcnt_t
TYPEDEF: int blksize_t
TYPEDEF: int pid_t
TYPEDEF: long time_t
TYPEDEF: ulong fsblkcnt_t
TYPEDEF: ulong fsfilcnt_t
TYPEDEF: ulong ino64_t
TYPEDEF: void* posix_spawn_file_actions_t
TYPEDEF: void* posix_spawnattr_t
TYPEDEF: ulong[4] sigset_t

STRUCT: sched_param
    { sched_priority int } ;
