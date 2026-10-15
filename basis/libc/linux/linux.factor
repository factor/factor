USING: alien.c-types alien.strings alien.syntax destructors kernel literals system vocabs ;
IN: libc

LIBRARY: libc

CONSTANT: EPERM 1
CONSTANT: ENOENT 2
CONSTANT: ESRCH 3
CONSTANT: EINTR 4
CONSTANT: EIO 5
CONSTANT: ENXIO 6
CONSTANT: E2BIG 7
CONSTANT: ENOEXEC 8
CONSTANT: EBADF 9
CONSTANT: ECHILD 10
CONSTANT: EAGAIN 11
CONSTANT: ENOMEM 12
CONSTANT: EACCES 13
CONSTANT: EFAULT 14
CONSTANT: ENOTBLK 15
CONSTANT: EBUSY 16
CONSTANT: EEXIST 17
CONSTANT: EXDEV 18
CONSTANT: ENODEV 19
CONSTANT: ENOTDIR 20
CONSTANT: EISDIR 21
CONSTANT: EINVAL 22
CONSTANT: ENFILE 23
CONSTANT: EMFILE 24
CONSTANT: ENOTTY 25
CONSTANT: ETXTBSY 26
CONSTANT: EFBIG 27
CONSTANT: ENOSPC 28
CONSTANT: ESPIPE 29
CONSTANT: EROFS 30
CONSTANT: EMLINK 31
CONSTANT: EPIPE 32
CONSTANT: EDOM 33
CONSTANT: ERANGE 34
CONSTANT: EDEADLK $[ cpu mips? 45 35 ? ]
CONSTANT: ENAMETOOLONG $[ cpu mips? 78 36 ? ]
CONSTANT: ENOLCK $[ cpu mips? 46 37 ? ]
CONSTANT: ENOSYS $[ cpu mips? 89 38 ? ]
CONSTANT: ENOTEMPTY $[ cpu mips? 93 39 ? ]
CONSTANT: ELOOP $[ cpu mips? 90 40 ? ]
ALIAS: EWOULDBLOCK EAGAIN
CONSTANT: ENOMSG $[ cpu mips? 35 42 ? ]
CONSTANT: EIDRM $[ cpu mips? 36 43 ? ]
CONSTANT: ECHRNG $[ cpu mips? 37 44 ? ]
CONSTANT: EL2NSYNC $[ cpu mips? 38 45 ? ]
CONSTANT: EL3HLT $[ cpu mips? 39 46 ? ]
CONSTANT: EL3RST $[ cpu mips? 40 47 ? ]
CONSTANT: ELNRNG $[ cpu mips? 41 48 ? ]
CONSTANT: EUNATCH $[ cpu mips? 42 49 ? ]
CONSTANT: ENOCSI $[ cpu mips? 43 50 ? ]
CONSTANT: EL2HLT $[ cpu mips? 44 51 ? ]
CONSTANT: EBADE $[ cpu mips? 50 52 ? ]
CONSTANT: EBADR $[ cpu mips? 51 53 ? ]
CONSTANT: EXFULL $[ cpu mips? 52 54 ? ]
CONSTANT: ENOANO $[ cpu mips? 53 55 ? ]
CONSTANT: EBADRQC $[ cpu mips? 54 56 ? ]
CONSTANT: EBADSLT $[ cpu mips? 55 57 ? ]
CONSTANT: EDEADLOCK $[ cpu mips? 56 35 ? ]
CONSTANT: EBFONT 59
CONSTANT: ENOSTR 60
CONSTANT: ENODATA 61
CONSTANT: ETIME 62
CONSTANT: ENOSR 63
CONSTANT: ENONET 64
CONSTANT: ENOPKG 65
CONSTANT: EREMOTE 66
CONSTANT: ENOLINK 67
CONSTANT: EADV 68
CONSTANT: ESRMNT 69
CONSTANT: ECOMM 70
CONSTANT: EPROTO 71
CONSTANT: EMULTIHOP $[ cpu mips? 74 72 ? ]
CONSTANT: EDOTDOT 73
CONSTANT: EBADMSG $[ cpu mips? 77 74 ? ]
CONSTANT: EOVERFLOW $[ cpu mips? 79 75 ? ]
CONSTANT: ENOTUNIQ $[ cpu mips? 80 76 ? ]
CONSTANT: EBADFD $[ cpu mips? 81 77 ? ]
CONSTANT: EREMCHG $[ cpu mips? 82 78 ? ]
CONSTANT: ELIBACC $[ cpu mips? 83 79 ? ]
CONSTANT: ELIBBAD $[ cpu mips? 84 80 ? ]
CONSTANT: ELIBSCN $[ cpu mips? 85 81 ? ]
CONSTANT: ELIBMAX $[ cpu mips? 86 82 ? ]
CONSTANT: ELIBEXEC $[ cpu mips? 87 83 ? ]
CONSTANT: EILSEQ $[ cpu mips? 88 84 ? ]
CONSTANT: ERESTART $[ cpu mips? 91 85 ? ]
CONSTANT: ESTRPIPE $[ cpu mips? 92 86 ? ]
CONSTANT: EUSERS $[ cpu mips? 94 87 ? ]
CONSTANT: ENOTSOCK $[ cpu mips? 95 88 ? ]
CONSTANT: EDESTADDRREQ $[ cpu mips? 96 89 ? ]
CONSTANT: EMSGSIZE $[ cpu mips? 97 90 ? ]
CONSTANT: EPROTOTYPE $[ cpu mips? 98 91 ? ]
CONSTANT: ENOPROTOOPT $[ cpu mips? 99 92 ? ]
CONSTANT: EPROTONOSUPPORT $[ cpu mips? 120 93 ? ]
CONSTANT: ESOCKTNOSUPPORT $[ cpu mips? 121 94 ? ]
CONSTANT: EOPNOTSUPP $[ cpu mips? 122 95 ? ]
CONSTANT: EPFNOSUPPORT $[ cpu mips? 123 96 ? ]
CONSTANT: EAFNOSUPPORT $[ cpu mips? 124 97 ? ]
CONSTANT: EADDRINUSE $[ cpu mips? 125 98 ? ]
CONSTANT: EADDRNOTAVAIL $[ cpu mips? 126 99 ? ]
CONSTANT: ENETDOWN $[ cpu mips? 127 100 ? ]
CONSTANT: ENETUNREACH $[ cpu mips? 128 101 ? ]
CONSTANT: ENETRESET $[ cpu mips? 129 102 ? ]
CONSTANT: ECONNABORTED $[ cpu mips? 130 103 ? ]
CONSTANT: ECONNRESET $[ cpu mips? 131 104 ? ]
CONSTANT: ENOBUFS $[ cpu mips? 132 105 ? ]
CONSTANT: EISCONN $[ cpu mips? 133 106 ? ]
CONSTANT: ENOTCONN $[ cpu mips? 134 107 ? ]
CONSTANT: ESHUTDOWN $[ cpu mips? 143 108 ? ]
CONSTANT: ETOOMANYREFS $[ cpu mips? 144 109 ? ]
CONSTANT: ETIMEDOUT $[ cpu mips? 145 110 ? ]
CONSTANT: ECONNREFUSED $[ cpu mips? 146 111 ? ]
CONSTANT: EHOSTDOWN $[ cpu mips? 147 112 ? ]
CONSTANT: EHOSTUNREACH $[ cpu mips? 148 113 ? ]
CONSTANT: EALREADY $[ cpu mips? 149 114 ? ]
CONSTANT: EINPROGRESS $[ cpu mips? 150 115 ? ]
CONSTANT: ESTALE $[ cpu mips? 151 116 ? ]
CONSTANT: EUCLEAN $[ cpu mips? 135 117 ? ]
CONSTANT: ENOTNAM $[ cpu mips? 137 118 ? ]
CONSTANT: ENAVAIL $[ cpu mips? 138 119 ? ]
CONSTANT: EISNAM $[ cpu mips? 139 120 ? ]
CONSTANT: EREMOTEIO $[ cpu mips? 140 121 ? ]
CONSTANT: EDQUOT $[ cpu mips? 1133 122 ? ]
CONSTANT: ENOMEDIUM $[ cpu mips? 159 123 ? ]
CONSTANT: EMEDIUMTYPE $[ cpu mips? 160 124 ? ]
CONSTANT: ECANCELED $[ cpu mips? 158 125 ? ]
CONSTANT: ENOKEY $[ cpu mips? 161 126 ? ]
CONSTANT: EKEYEXPIRED $[ cpu mips? 162 127 ? ]
CONSTANT: EKEYREVOKED $[ cpu mips? 163 128 ? ]
CONSTANT: EKEYREJECTED $[ cpu mips? 164 129 ? ]
CONSTANT: EOWNERDEAD $[ cpu mips? 165 130 ? ]
CONSTANT: ENOTRECOVERABLE $[ cpu mips? 166 131 ? ]

CONSTANT: SIGHUP           1
CONSTANT: SIGINT           2
CONSTANT: SIGQUIT          3
CONSTANT: SIGILL           4
CONSTANT: SIGTRAP          5
CONSTANT: SIGABRT          6
CONSTANT: SIGIOT           6
! Linux/MIPS uses the historical MIPS errno and signal numbering.
! Compute each differing literal on every load, including image refreshes.
CONSTANT: SIGEMT $[ cpu mips? 7 f ? ]
CONSTANT: SIGBUS $[ cpu mips? 10 7 ? ]
CONSTANT: SIGFPE           8
CONSTANT: SIGKILL          9
CONSTANT: SIGUSR1 $[ cpu mips? 16 10 ? ]
CONSTANT: SIGSEGV         11
CONSTANT: SIGUSR2 $[ cpu mips? 17 12 ? ]
CONSTANT: SIGPIPE         13
CONSTANT: SIGALRM         14
CONSTANT: SIGTERM         15
CONSTANT: SIGSTKFLT $[ cpu mips? f 16 ? ]
CONSTANT: SIGCHLD $[ cpu mips? 18 17 ? ]
ALIAS:    SIGCLD          SIGCHLD
CONSTANT: SIGCONT $[ cpu mips? 25 18 ? ]
CONSTANT: SIGSTOP $[ cpu mips? 23 19 ? ]
CONSTANT: SIGTSTP $[ cpu mips? 24 20 ? ]
CONSTANT: SIGTTIN $[ cpu mips? 26 21 ? ]
CONSTANT: SIGTTOU $[ cpu mips? 27 22 ? ]
CONSTANT: SIGURG $[ cpu mips? 21 23 ? ]
CONSTANT: SIGXCPU $[ cpu mips? 30 24 ? ]
CONSTANT: SIGXFSZ $[ cpu mips? 31 25 ? ]
CONSTANT: SIGVTALRM $[ cpu mips? 28 26 ? ]
CONSTANT: SIGPROF $[ cpu mips? 29 27 ? ]
CONSTANT: SIGWINCH $[ cpu mips? 20 28 ? ]
CONSTANT: SIGIO $[ cpu mips? 22 29 ? ]
ALIAS:    SIGPOLL         SIGIO
CONSTANT: SIGPWR $[ cpu mips? 19 30 ? ]
CONSTANT: SIGSYS $[ cpu mips? 12 31 ? ]

! Both glibc and musl export this POSIX entry point. Their public
! strerror_r symbols have different return types (char* versus int).
FUNCTION-ALIAS: strerror_r
    int __xpg_strerror_r ( int errno, char* buf, size_t buflen )

M: linux strerror
    [
        1024 [ malloc &free ] keep [ strerror_r ] keepd nip
        alien>native-string
    ] with-destructors ;

CONSTANT: LC_CTYPE           0
CONSTANT: LC_NUMERIC         1
CONSTANT: LC_TIME            2
CONSTANT: LC_COLLATE         3
CONSTANT: LC_MONETARY        4
CONSTANT: LC_MESSAGES        5
CONSTANT: LC_ALL             6
CONSTANT: LC_PAPER           7
CONSTANT: LC_NAME            8
CONSTANT: LC_ADDRESS         9
CONSTANT: LC_TELEPHONE       10
CONSTANT: LC_MEASUREMENT     11
CONSTANT: LC_IDENTIFICATION  12

cpu alpha.64? [ "libc.linux.alpha" require ] when

cpu sparc? [ "libc.linux.sparc" require ] when

cpu hppa? [ "libc.linux.hppa" require ] when
