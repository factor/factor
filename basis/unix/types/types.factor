USING: accessors alien.c-types alien.syntax system vocabs ;
QUALIFIED: sequences
IN: unix.types

TYPEDEF: uchar u_int8_t
TYPEDEF: ushort u_int16_t
TYPEDEF: uint u_int32_t
TYPEDEF: ulonglong u_int64_t

TYPEDEF: char __int8_t
TYPEDEF: short __int16_t
TYPEDEF: int __int32_t
TYPEDEF: longlong __int64_t

TYPEDEF: uchar __uint8_t
TYPEDEF: ushort __uint16_t
TYPEDEF: uint __uint32_t
TYPEDEF: ulonglong __uint64_t

TYPEDEF: void* caddr_t
TYPEDEF: uint in_addr_t
TYPEDEF: uint socklen_t

TYPEDEF: __uint64_t fsblkcnt_t
TYPEDEF: fsblkcnt_t __fsblkcnt_t
TYPEDEF: __uint64_t fsfilcnt_t
TYPEDEF: fsfilcnt_t __fsfilcnt_t
TYPEDEF: __uint64_t rlim_t
TYPEDEF: uint32_t id_t
TYPEDEF: long clockid_t

C-TYPE: DIR
C-TYPE: FILE
C-TYPE: rlimit
C-TYPE: rusage
C-TYPE: sockaddr

"unix.types." os name>> sequences:append require
