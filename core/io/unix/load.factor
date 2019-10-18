USE: kernel

REQUIRES: core/io/buffer ;

PROVIDE: core/io/unix
{ +files+ {
    "types.factor"
    { "syscalls-freebsd.factor" [ os "freebsd" = ] }
    { "syscalls-linux.factor" [ os "linux" = ] }
    { "syscalls-macosx.factor" [ os "macosx" = ] }
    { "syscalls-solaris.factor" [ os "solaris" = ] }
    "syscalls.factor"
    "io.factor"
    "sockets.factor"
    "files.factor"
} } ;
