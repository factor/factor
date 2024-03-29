USING: alien.c-types alien.strings alien.syntax destructors
io.encodings.utf8 kernel libc system ;
IN: libc

LIBRARY: libc

! From errno.h in msvc 10:
CONSTANT: EPERM           1
CONSTANT: ENOENT          2
CONSTANT: ESRCH           3
CONSTANT: EINTR           4
CONSTANT: EIO             5
CONSTANT: ENXIO           6
CONSTANT: E2BIG           7
CONSTANT: ENOEXEC         8
CONSTANT: EBADF           9
CONSTANT: ECHILD          10
CONSTANT: EAGAIN          11
CONSTANT: ENOMEM          12
CONSTANT: EACCES          13
CONSTANT: EFAULT          14
CONSTANT: EBUSY           16
CONSTANT: EEXIST          17
CONSTANT: EXDEV           18
CONSTANT: ENODEV          19
CONSTANT: ENOTDIR         20
CONSTANT: EISDIR          21
CONSTANT: ENFILE          23
CONSTANT: EMFILE          24
CONSTANT: ENOTTY          25
CONSTANT: EFBIG           27
CONSTANT: ENOSPC          28
CONSTANT: ESPIPE          29
CONSTANT: EROFS           30
CONSTANT: EMLINK          31
CONSTANT: EPIPE           32
CONSTANT: EDOM            33
CONSTANT: EDEADLK         36
CONSTANT: ENAMETOOLONG    38
CONSTANT: ENOLCK          39
CONSTANT: ENOSYS          40
CONSTANT: ENOTEMPTY       41

! Error codes used in the Secure CRT functions
CONSTANT: EINVAL          22
CONSTANT: ERANGE          34
CONSTANT: EILSEQ          42
CONSTANT: STRUNCATE       80

! Support EDEADLOCK for compatibility with older MS-C versions
ALIAS: EDEADLOCK       EDEADLK

! POSIX SUPPLEMENT
CONSTANT: EADDRINUSE      100
CONSTANT: EADDRNOTAVAIL   101
CONSTANT: EAFNOSUPPORT    102
CONSTANT: EALREADY        103
CONSTANT: EBADMSG         104
CONSTANT: ECANCELED       105
CONSTANT: ECONNABORTED    106
CONSTANT: ECONNREFUSED    107
CONSTANT: ECONNRESET      108
CONSTANT: EDESTADDRREQ    109
CONSTANT: EHOSTUNREACH    110
CONSTANT: EIDRM           111
CONSTANT: EINPROGRESS     112
CONSTANT: EISCONN         113
CONSTANT: ELOOP           114
CONSTANT: EMSGSIZE        115
CONSTANT: ENETDOWN        116
CONSTANT: ENETRESET       117
CONSTANT: ENETUNREACH     118
CONSTANT: ENOBUFS         119
CONSTANT: ENODATA         120
CONSTANT: ENOLINK         121
CONSTANT: ENOMSG          122
CONSTANT: ENOPROTOOPT     123
CONSTANT: ENOSR           124
CONSTANT: ENOSTR          125
CONSTANT: ENOTCONN        126
CONSTANT: ENOTRECOVERABLE 127
CONSTANT: ENOTSOCK        128
CONSTANT: ENOTSUP         129
CONSTANT: EOPNOTSUPP      130
CONSTANT: EOTHER          131
CONSTANT: EOVERFLOW       132
CONSTANT: EOWNERDEAD      133
CONSTANT: EPROTO          134
CONSTANT: EPROTONOSUPPORT 135
CONSTANT: EPROTOTYPE      136
CONSTANT: ETIME           137
CONSTANT: ETIMEDOUT       138
CONSTANT: ETXTBSY         139
CONSTANT: EWOULDBLOCK     140

! From signal.h in msvc 10:
CONSTANT: SIGINT          2
CONSTANT: SIGILL          4
CONSTANT: SIGFPE          8
CONSTANT: SIGSEGV         11
CONSTANT: SIGTERM         15
CONSTANT: SIGBREAK        21
CONSTANT: SIGABRT         22

CONSTANT: SIGABRT_COMPAT  6

LIBRARY: libc

FUNCTION: int strerror_s ( char *buffer, size_t numberOfElements, int errnum )

M: windows strerror
    [
        [ 1024 [ malloc &free ] keep ] dip
        [ strerror_s drop ] keepdd
        utf8 alien>string
    ] with-destructors ;

! These are uncertain:
CONSTANT: LC_ALL 0
CONSTANT: LC_COLLATE 1
CONSTANT: LC_CTYPE 2
CONSTANT: LC_MONETARY 3
CONSTANT: LC_NUMERIC 4
CONSTANT: LC_TIME 5
