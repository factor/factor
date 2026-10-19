USING: alien.c-types alien.syntax classes.struct ;
IN: unix.types

TYPEDEF: long clockid_t
TYPEDEF: uint dev_t
TYPEDEF: ulonglong ino_t
TYPEDEF: ushort mode_t
TYPEDEF: uint nlink_t
TYPEDEF: uint uid_t
TYPEDEF: uint gid_t
TYPEDEF: longlong off_t
TYPEDEF: longlong blkcnt_t
TYPEDEF: longlong ino64_t
TYPEDEF: longlong blksize_t
TYPEDEF: uint fflags_t
TYPEDEF: int pid_t
TYPEDEF: longlong time_t
TYPEDEF: long suseconds_t

TYPEDEF: uint[4] sigset_t
TYPEDEF: void* posix_spawn_file_actions_t
TYPEDEF: void* posix_spawnattr_t
