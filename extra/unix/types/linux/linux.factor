
USING: alien.syntax ;

IN: unix.types

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TYPEDEF: ulonglong __uquad_type
TYPEDEF: ulong     __ulongword_type
TYPEDEF: long      __sword_type
TYPEDEF: ulong     __uword_type
TYPEDEF: long      __slongword_type
TYPEDEF: uint      __u32_type
TYPEDEF: int       __s32_type 

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TYPEDEF: __uquad_type     dev_t
TYPEDEF: __ulongword_type ino_t
TYPEDEF: __u32_type       mode_t
TYPEDEF: __uword_type     nlink_t
TYPEDEF: __u32_type       uid_t
TYPEDEF: __u32_type       gid_t
TYPEDEF: __slongword_type off_t
TYPEDEF: __slongword_type blksize_t
TYPEDEF: __slongword_type blkcnt_t
TYPEDEF: __sword_type     ssize_t
TYPEDEF: __s32_type       pid_t
TYPEDEF: __slongword_type time_t